# frozen_string_literal: true

ActiveAdmin.register Location do
  permit_params :name, :address
end
