# frozen_string_literal: true

class TeamSection < ApplicationRecord
  belongs_to :team, inverse_of: :team_sections
  belongs_to :section, inverse_of: :team_sections
end
