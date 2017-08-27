ActiveAdmin.register Day do
  permit_params :name, :calendar_id, :season_id, :period_start_date, :period_end_date
end