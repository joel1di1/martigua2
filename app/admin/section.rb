ActiveAdmin.register Section do
  permit_params :name, :club_id

  index do
    column :id
    column :club
    column :to_s
    column :name
    column :created_at
    column :updated_at
    actions
  end

  form do |f|
    f.inputs "Details" do
      f.input :club
      f.input :name
    end
    f.actions
  end
end
