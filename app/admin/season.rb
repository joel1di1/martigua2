ActiveAdmin.register Season do
  permit_params :name, :start_date, :end_date
end