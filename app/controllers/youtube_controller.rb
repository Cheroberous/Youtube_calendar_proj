require 'google/apis/youtube_v3'
require "google/api_client/client_secrets.rb"

class YoutubeController < ApplicationController
    def youtubeListProva
        client = get_google_youtube_client current_user
        @dati = client.list_channels("UCTo-Iq6sT4-tevlofZzid4A")
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

    def upload
      mainUpload
    end

    def videoCaricati
      mainCaricati
    end

    def mainUpload
      opts = Trollop::options do
        opt :file, 'Video file to upload', :type => String
        opt :title, 'Video title', :default => 'Test Title', :type => String
        opt :description, 'Video description',
              :default => 'Test Description', :type => String
        opt :category_id, 'Numeric video category. See https://developers.google.com/youtube/v3/docs/videoCategories/list',
              :default => 22, :type => :int
        opt :keywords, 'Video keywords, comma-separated',
              :default => '', :type => String
        opt :privacy_status, 'Video privacy status: public, private, or unlisted',
              :default => 'public', :type => String
      end
    
      if opts[:file].nil? or not File.file?(opts[:file])
        Trollop::die :file, 'does not exist'
      end
    
      client, youtube = get_authenticated_service
    
      begin
        body = {
          :snippet => {
            :title => opts[:title],
            :description => opts[:description],
            :tags => opts[:keywords].split(','),
            :categoryId => opts[:category_id],
          },
          :status => {
            :privacyStatus => opts[:privacy_status]
          }
        }
    
        videos_insert_response = client.execute!(
          :api_method => youtube.videos.insert,
          :body_object => body,
          :media => Google::APIClient::UploadIO.new(opts[:file], 'video/*'),
          :parameters => {
            :uploadType => 'resumable',
            :part => body.keys.join(',')
          }
        )
    
        videos_insert_response.resumable_upload.send_all(client)
    
        puts "Video id '#{videos_insert_response.data.id}' was successfully uploaded."
      rescue Google::APIClient::TransmissionError => e
        puts e.result.body
      end
    end

    def mainCaricati
      client, youtube = get_authenticated_service
    
      begin
        # Retrieve the "contentDetails" part of the channel resource for the
        # authenticated user's channel.
        channels_response = client.execute!(
          :api_method => youtube.channels.list,
          :parameters => {
            :mine => true,
            :part => 'contentDetails'
          }
        )
    
        channels_response.data.items.each do |channel|
          # From the API response, extract the playlist ID that identifies the list
          # of videos uploaded to the authenticated user's channel.
          uploads_list_id = channel['contentDetails']['relatedPlaylists']['uploads']
    
          # Retrieve the list of videos uploaded to the authenticated user's channel.
          next_page_token = ''
          until next_page_token.nil?
            playlistitems_response = client.execute!(
              :api_method => youtube.playlist_items.list,
              :parameters => {
                :playlistId => uploads_list_id,
                :part => 'snippet',
                :maxResults => 50,
                :pageToken => next_page_token
              }
            )
    
            puts "Videos in list #{uploads_list_id}"
    
            # Print information about each video.
            playlistitems_response.data.items.each do |playlist_item|
              title = playlist_item['snippet']['title']
              video_id = playlist_item['snippet']['resourceId']['videoId']
    
              puts "#{title} (#{video_id})"
            end
    
            next_page_token = playlistitems_response.next_page_token
          end
    
          puts
        end
      rescue Google::APIClient::TransmissionError => e
        puts e.result.body
      end
    end
    

    def get_google_youtube_client current_user
        client = Google::Apis::YoutubeV3::YouTubeService.new

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
