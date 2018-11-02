ActiveAdmin.register Training do
  permit_params :start_datetime, :end_datetime, :location_id, :canceled, :cancelation_reason

  form do |f|
    f.inputs do
      f.input :start_datetime, :as => :datetime_picker
      f.input :end_datetime, :as => :datetime_picker
      f.input :location
      f.input :cancelled
      f.input :cancel_reason
      f.actions
    end
  end
end
