json.array!(@matches) do |match|
  json.extract! match, :id, :championship_id, :local_team_id, :visitor_team_id, :start_datetime, :end_datetime, :prevision_period_start, :prevision_period_end, :local_score, :visitor_score, :location_id, :meeting_datetime, :meeting_location
  json.url match_url(match, format: :json)
end
