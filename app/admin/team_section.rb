# frozen_string_literal: true

ActiveAdmin.register TeamSection do
  permit_params :team_id, :section_id
end
