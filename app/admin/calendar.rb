# frozen_string_literal: true

ActiveAdmin.register Calendar do
  permit_params :name, :season_id
end
