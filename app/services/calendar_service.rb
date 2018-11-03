require 'google/apis/calendar_v3'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'googleauth/stores/redis_token_store'

require 'fileutils'
require 'date'

class CalendarService
  OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'.freeze
  APPLICATION_NAME = 'Martigua2'.freeze
  CREDENTIALS_PATH = File.join(Dir.home, '.credentials', "calendar-ruby-quickstart.yaml")
  SCOPE = Google::Apis::CalendarV3::AUTH_CALENDAR
  CLIENT_SECRETS_PATH = 'google_client_secret.json'.freeze
  GOOGLE_CALENDAR_ID = ENV['GOOGLE_CALENDAR_ID'] || '24l3f4bf1u4fut3gdjpb2pfq94@group.calendar.google.com'

  include Singleton

  def initialize
    gcalendar_service
  end

  def gcalendar_service
    @gcalendar_service ||= new_gcalendar_service
  end

  def new_gcalendar_service
    service = Google::Apis::CalendarV3::CalendarService.new
    service.client_options.application_name = APPLICATION_NAME
    service.authorization = authorize
    service
  end

  def create_client_id
    if Rails.env.development? || Rails.env.test?
      Google::Auth::ClientId.from_file(CLIENT_SECRETS_PATH)
    else
      Google::Auth::ClientId.new(Rails.application.secrets.google_client_id, Rails.application.secrets.google_client_secret)
    end
  end

  def create_token_store
    if Rails.env.development? || Rails.env.test?
      FileUtils.mkdir_p(File.dirname(CREDENTIALS_PATH))
      Google::Auth::Stores::FileTokenStore.new(file: CREDENTIALS_PATH)
    else
      Google::Auth::Stores::RedisTokenStore.new(redis: Redis.new)
    end
  end

  def build_gcalendar_event(summary, description, starttime, endtime, location)
    Google::Apis::CalendarV3::Event.new(
      summary: summary,
      description: description,
      start: Google::Apis::CalendarV3::EventDateTime.new(
        date_time: starttime.to_datetime.rfc3339
      ),
      end: Google::Apis::CalendarV3::EventDateTime.new(
        date_time: endtime.to_datetime.rfc3339
      ),
      location: location,
      anyone_can_add_self: true
    )
  end

  def create_or_update_event(event_id, summary, description, starttime, endtime, location)
    if event_id
      update_event(event_id, summary, description, starttime, endtime, location)
    else
      add_event(summary, description, starttime, endtime, location)
    end
  end

  def add_event(summary, description, starttime, endtime, location)
    event = build_gcalendar_event(summary, description, starttime, endtime, location)
    gcalendar_service.insert_event(GOOGLE_CALENDAR_ID, event)
  end

  def update_event(event_id, summary, description, starttime, endtime, location)
    event = build_gcalendar_event(summary, description, starttime, endtime, location)
    gcalendar_service.update_event(GOOGLE_CALENDAR_ID, event_id, event)
  end

  def display_events
    # Fetch the next 10 events for the user
    response = gcalendar_service.list_events(GOOGLE_CALENDAR_ID,
                                             max_results: 10,
                                             single_events: true,
                                             order_by: 'startTime',
                                             time_min: Time.now.iso8601)

    puts "Upcoming events:"
    puts "No upcoming events found" if response.items.empty?
    response.items.each do |event|
      start = event.start.date || event.start.date_time
      puts "- #{event.summary} (#{start})"
    end
  end

  ##
  # Ensure valid credentials, either by restoring from the saved credentials
  # files or intitiating an OAuth2 authorization. If authorization is required,
  # the user's default browser will be launched to approve the request.
  #
  # @return [Google::Auth::UserRefreshCredentials] OAuth2 credentials
  def authorize
    client_id = create_client_id
    token_store = create_token_store

    authorizer = Google::Auth::UserAuthorizer.new(client_id, SCOPE, token_store)
    user_id = 'default'
    credentials = authorizer.get_credentials(user_id)
    if credentials.nil?
      url = authorizer.get_authorization_url(
        base_url: OOB_URI
      )
      puts "Open the following URL in the browser and enter the " \
           "resulting code after authorization"
      puts url
      code = gets
      credentials = authorizer.get_and_store_credentials_from_code(
        user_id: user_id, code: code, base_url: OOB_URI
      )
    end
    credentials
  end
end
