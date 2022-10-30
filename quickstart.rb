# Sample Ruby code for user authorization

require 'rubygems'
gem 'google-api-client', '>0.7'
require 'google/apis'
require 'google/apis/youtube_v3'
require 'googleauth'
require 'googleauth/stores/file_token_store'


require 'fileutils'
require 'json'

# REPLACE WITH VALID REDIRECT_URI FOR YOUR CLIENT
REDIRECT_URI = 'http://localhost:3000/oauth2callback'
APPLICATION_NAME = 'Progetto LASSI'

# REPLACE WITH NAME/LOCATION OF YOUR client_secrets.json FILE
    # /home/alessio/Youtube_calendar_proj/client_secret_794549070680-r5p4t5si58vsvvtbb303u3ffa8m8a7rt.apps.googleusercontent.com.json
CLIENT_SECRETS_PATH = 'client_secret.json'

# REPLACE FINAL ARGUMENT WITH FILE WHERE CREDENTIALS WILL BE STORED
CREDENTIALS_PATH = "youtube-quickstart-ruby-credentials.yaml"

# SCOPE FOR WHICH THIS SCRIPT REQUESTS AUTHORIZATION
SCOPE = ['https://www.googleapis.com/auth/calendar',
'https://www.googleapis.com/auth/calendar.events',
'https://www.googleapis.com/auth/calendar.events.readonly',
'https://www.googleapis.com/auth/calendar.readonly',
'https://www.googleapis.com/auth/calendar.settings.readonly',
'https://www.googleapis.com/auth/youtube',
'https://www.googleapis.com/auth/youtube.force-ssl',
'https://www.googleapis.com/auth/youtube.readonly',
'https://www.googleapis.com/auth/youtube.upload',
'https://www.googleapis.com/auth/youtubepartner',
'https://www.googleapis.com/auth/youtubepartner-channel-audit']

# https://www.googleapis.com/auth/calendar, 
# https://www.googleapis.com/auth/calendar.events, 
# https://www.googleapis.com/auth/calendar.events.readonly, 
# https://www.googleapis.com/auth/calendar.readonly,
# https://www.googleapis.com/auth/calendar.settings.readonly,

# https://www.googleapis.com/auth/youtube,
# https://www.googleapis.com/auth/youtube.force-ssl,
# https://www.googleapis.com/auth/youtube.readonly,
# https://www.googleapis.com/auth/youtube.upload,
# https://www.googleapis.com/auth/youtubepartner,
# https://www.googleapis.com/auth/youtubepartner-channel-audit

def authorize
  FileUtils.mkdir_p(File.dirname(CREDENTIALS_PATH))

  client_id = Google::Auth::ClientId.from_file(CLIENT_SECRETS_PATH)
  token_store = Google::Auth::Stores::FileTokenStore.new(file: CREDENTIALS_PATH)
  authorizer = Google::Auth::UserAuthorizer.new(
    client_id, SCOPE, token_store)
  user_id = 'default'
  credentials = authorizer.get_credentials(user_id)
  if credentials.nil?
    url = authorizer.get_authorization_url(base_url: REDIRECT_URI)
    puts "Open the following URL in the browser and enter the " +
         "resulting code after authorization"
    puts url
    code = gets
    credentials = authorizer.get_and_store_credentials_from_code(
      user_id: user_id, code: code, base_url: REDIRECT_URI)
  end
  credentials
end

# Initialize the API
service = Google::Apis::YoutubeV3::YouTubeService.new
service.client_options.application_name = APPLICATION_NAME
service.authorization = authorize

# Sample ruby code for channels.list

def channels_list_by_username(service, part, **params)
  response = service.list_channels(part, for_username: 'GoogleDevelopers').to_json
  item = JSON.parse(response).fetch("items")[0]

  puts ("This channel's ID is #{item.fetch("id")}. " +
        "Its title is '#{item.fetch("snippet").fetch("title")}', and it has " +
        "#{item.fetch("statistics").fetch("viewCount")} views.")

    puts CREDENTIALS_PATH 
end

channels_list_by_username(service, 'snippet,contentDetails,statistics', for_username: 'GoogleDevelopers')


# drive = Google::Apis::DriveV3::DriveService.new
# drive.client_options.application_name = APPLICATION_NAME
# drive.authorization = authorize # See Googleauth or Signet libraries

# # Search for files in Drive (first page only)
# files = drive.list_files(q: "title contains 'finances'")
# files.items.each do |file|
#   puts file.title
# end

# # Upload a file
# metadata = Google::Apis::DriveV3::File.new(name: 'test.txt')
# metadata = drive.create_file(metadata, upload_source: '/tmp/test.txt', content_type: 'text/plain')

# # Download a file
# drive.get_file(metadata.id, download_dest: '/tmp/downloaded-test.txt')