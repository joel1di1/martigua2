# frozen_string_literal: true

json.extract! @match, :id, :championship_id, :local_team_id, :visitor_team_id, :start_datetime, :end_datetime,
              :local_score, :visitor_score, :location_id, :meeting_datetime, :meeting_location, :created_at, :updated_at
