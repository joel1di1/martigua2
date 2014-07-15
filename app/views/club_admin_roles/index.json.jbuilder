json.array!(@club_admin_roles) do |club_admin_role|
  json.extract! club_admin_role, :id, :club_id, :user_id, :name
  json.url club_admin_role_url(club_admin_role, format: :json)
end
