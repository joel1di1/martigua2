ActiveAdmin.register Section do
  permit_params :name, :club_id

  form do |f|
    f.inputs "Details" do
      f.input :club
      f.input :name
    end
  end
end