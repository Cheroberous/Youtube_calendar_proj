require "google/apis/calendar_v3"
require "google/api_client/client_secrets.rb"
require "json"

# Sistemare refresh token, non richiede nuovo token

class CalendarController < ApplicationController
    def new
        @calendar = Calendar.new
    end

    def create
        userID = params[:userID]

        client = get_google_calendar_client current_user
        calendarList = client.list_calendar_lists()

        hash = makeHash(current_user.id, userID)

        calendarList.items.each do |calendar|
            if calendar.summary === "MMY_USER_#{hash}"
                # CONTROLLARE SE calendarID sono uguali

                if !Calendar.exists?(:hash => hash)
                    foundCalendar = Calendar.where(:hash => hash)
                    aclCalendarList = client.lists_acls(foundCalendar.calendarId)
                    acl = aclCalendarList.items.first

                    calendarToSave = newCalendar(calendar, userID, hash, acl.id)
    
                    # Sistemare, salva ma da errore
                    calendarToSave.save
                end
                
                redirect_to manager_path()
                return 
            end
        end

        googleCalendar = Google::Apis::CalendarV3::Calendar.new(
            summary: "MMY_USER_#{hash}",
            time_zone: 'Europe/Rome'
        )
    
        # Creo calendar con Google API
        createdCalendar = client.insert_calendar(googleCalendar)

        # Inserisco l'utente nelle ACL del calendario appena creato
        user = User.find(userID)
        userEmail = user.email

        # Creo ACL che permette condivisione del calendario appena creato con il relativo cliente.
        rule = Google::Apis::CalendarV3::AclRule.new(
            scope: {
                type: "user",
                value: userEmail 
            },
            # Attraverso tale role, il cliente avra potere di scrittura eventi ma non di modifica del calendario
            role: "writer"
        )
        # Google API Method per inserire le ACL appena create al Google Calendar
        result = client.insert_acl(createdCalendar.id, rule)

        # Aggiungo il Calendar appena creato al DB Calendars 
        calendarToSave = newCalendar(createdCalendar, userID, hash, result.id)
        # Da sistemare, salva ma da errore di conversione
        calendarToSave.save
    
        # calendar = Calendar.find_by(hash: hash)
        # redirect_to getCalendar_path(:selectedCalendarId => calendar.id)
        redirect_to manager_path()

    rescue Google::Apis::AuthorizationError
        rescueUnauthorized(client)
    end

    def list_manager_calendar
        client = get_google_calendar_client current_user
        calendarList = client.list_calendar_lists()

        calendarList.items.each do |calendar|
            # Creo Hash del calendario per controllare che questo sia gia presente nel Database
            hash = makeHash(calendar)

            if !Calendar.exists?(hash: hash)
                calendarToSave = Calendar.new(
                    calendarId: calendar.id,
                    summary: calendar.summary,
                    userId: current_user.id.to_s,
                    hash: hash
                )
                # Sistemare, non salva
                calendarToSave.save
            end
        end

        @calendarList = Calendar.where(userId: current_user.id)
    end

    def getCalendar
        selectedCalendar = params[:selectedCalendarId]
        @calendar = Calendar.find(selectedCalendar)
    end

    def delete
        userID = params[:userID]

        client = get_google_calendar_client current_user
        calendar = Calendar.find_by(managerId: current_user.id, userId: userID)

        if calendar
            client.delete_acl(calendar.calendarId, calendar.acl_id)
            client.delete_calendar(calendar.calendarId)

            Calendar.delete(calendar.id)
        end
        redirect_to manager_path()

    rescue Google::Apis::AuthorizationError
        rescueUnauthorized(client)
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

    def makeHash(managerID, userID)
        hash = Hash[
            managerID: managerID,
            userID: userID,
            summary: "MMY_USER_#{userID}"
        ].hash

        return hash.to_s
    end

    def newCalendar(calendar, userID, hash, acl_id)
        calendarToSave = Calendar.new(
            calendarId: calendar.id,
            summary: calendar.summary,
            managerId: current_user.id,
            userId: userID,
            hash: hash.to_s,
            acl_id: acl_id
        )

        return calendarToSave
    end

    def rescueUnauthorized(client)
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
    end
end
    