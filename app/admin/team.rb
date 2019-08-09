# frozen_string_literal: true

ActiveAdmin.register Team do
  permit_params :name, :club_id
end
