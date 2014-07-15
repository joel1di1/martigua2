ActiveAdmin.register User do

  index do
    column :id
    column :email
    column :first_name
    column :last_name
    column :nickname
    column :phone_number
    column :current_sign_in_at
    column :created_at
    column :updated_at
    actions
  end

  permit_params :email
end