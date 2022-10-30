require "google/apis/calendar_v3"
require "google/api_client/client_secrets.rb"

require 'open-uri'
require 'date'
require 'securerandom'

class ClienteController < ApplicationController

    before_action:require_user_logged_in!
    before_action:are_you_a_client

    def search
        @users = User.all
    end

    def function
    end

    def visualize
        @profilatoId= params[:id]
        @profilato = User.find(params[:id])
        is_it_a_manager(@profilato)
    end

    def createEvent
        @event = Event.new
    end

    # OK, DA PROVARE CON POST
    def createEventConfirm
        event = params[:event]
        # Da sistemare con tutti i dati
        # @newEvent = Event.new()
        # @newEvent.summary = event[:summary]
        # @newEvent.save

        # Controlla la scelta di creazione della conferenza meet dal form
        if event[:meetConference]
            conferenceData = {
                create_request: {
                   request_id: SecureRandom.uuid
                }
            }
        else
            conferenceData = nil
        end 

        affilManager = Affiliation.find_by(cliente: current_user.id)
        managerRecord = User.find_by(id: affilManager.manager)

        # Email con prima lettera maiuscola, perchè?
        manager = Google::Apis::CalendarV3::EventAttendee.new(
            display_name: managerRecord.full_name,
            email: managerRecord.email,
            id: managerRecord.id, 
            organizer: true
        )

        calendarEvent = Google::Apis::CalendarV3::Event.new(
            summary: event[:summary],
            attendees: [manager],
            creator: Google::Apis::CalendarV3::Event::Creator.new(
                display_name: current_user.full_name,
                email: current_user.email,
                id: current_user.id
            ),
            description: "Prova Evento",
            start: Google::Apis::CalendarV3::EventDateTime.new(
                date: event[:date_attribute_start],
                time_zone: "Europe/Rome"
            ), 
            end: Google::Apis::CalendarV3::EventDateTime.new(
                date: event[:date_attribute_end],
                time_zone: "Europe/Rome"
            ),
            kind: "calendar#event",
            organizer: Google::Apis::CalendarV3::Event::Organizer.new(
                display_name: current_user.full_name,
                email: current_user.email,
                id: current_user.id
            ),
            source: Google::Apis::CalendarV3::Event::Source.new(
                title: "Create Event Method from Calendar Controller",
                url: "http://127.0.0.1/calendar/createCalendar"
            ),
            conference_data: conferenceData
        )

        calendar = Calendar.find_by(userId: current_user.id, managerId: managerRecord.id)

        client = get_google_calendar_client current_user
        @createdEvent = client.insert_event(calendar.calendarId, calendarEvent, conference_data_version: 1)

        eventRecord = Event.new()

        eventRecord.summary = @createdEvent.summary
        eventRecord.description = @createdEvent.description
        eventRecord.start = @createdEvent.start.date
        eventRecord.end = @createdEvent.end.date
        eventRecord.meetCode = @createdEvent.conference_data.conference_id
        eventRecord.calendarID = calendar.calendarId
        eventRecord.eventID = @createdEvent.id
        eventRecord.managerID= managerRecord.id
        eventRecord.clienteID= current_user.id

        eventRecord.save

        # redirect_to '/manager/singleone?cliente='+ cliente.id.to_s

    rescue Google::Apis::AuthorizationError
        secrets = Google::APIClient::ClientSecrets.new({
            "web" => {
              "access_token" => current_user.access_token,
              "refresh_token" => current_user.refresh_token,
              "client_id" => ENV["GOOGLE_OAUTH_CLIENT_ID"],
              "client_secret" => ENV["GOOGLE_OAUTH_CLIENT_SECRET"]
            }
        })
        client.authorization = secrets.to_authorization
        client.authorization.grant_type = "refresh_token"

        client.authorization.refresh!
        current_user.update_attribute(:access_token, client.authorization.access_token)
        current_user.update_attribute(:refresh_token, client.authorization.refresh_token)
        retry
    end

    def editEvent
        @event = Event.find(params[:format])
    end

    def listEvent
        @eventList = Event.all
        @userID = params[:userID]
    end

    def reviewEvent
        event = params[:event]

        @event = Event.find(event[:eventID])

        client = get_google_calendar_client current_user

        eventToEdit = client.get_event(@event.calendarID, @event.eventID)

        eventToEdit.summary = event[:summary]
        eventToEdit.description = event[:description]
        eventToEdit.start.date = event[:start]
        eventToEdit.end.date = event[:end]
        eventToEdit.conference_data.conference_id = event[:meetCode]

        @editedEvent = client.patch_event(@event.calendarID, @event.eventID, eventToEdit)
        redirect_to manager_path()
    end

    def deleteEvent
        eventToDelete = Event.find(params[:event])

        client = get_google_calendar_client current_user

        if client.delete_event(eventToDelete.calendarID, eventToDelete.eventID)
            Event.delete(eventToDelete.id)
        end

        redirect_to manager_path()
    end

    def get_google_calendar_client current_user
        client = Google::Apis::CalendarV3::CalendarService.new
        return unless (current_user.present? && current_user.access_token.present? && current_user.refresh_token.present?)
        secrets = Google::APIClient::ClientSecrets.new({
          "web" => {
            "access_token" => current_user.access_token,
            "refresh_token" => current_user.refresh_token,
            "client_id" => ENV["GOOGLE_OAUTH_CLIENT_ID"],
            "client_secret" => ENV["GOOGLE_OAUTH_CLIENT_SECRET"]
          }
        })
        begin
          client.authorization = secrets.to_authorization
          client.authorization.grant_type = "refresh_token"
    
          if !current_user.present?
            client.authorization.refresh!
            current_user.update_attributes(
              access_token: client.authorization.access_token,
              refresh_token: client.authorization.refresh_token
            )
          end
        rescue => e
          flash[:error] = 'Your token has been expired. Please login again with google.'
          redirect_to :back
        end
        client
    end
end