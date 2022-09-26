# frozen_string_literal: true

class EnrolledTeamChampionship < ApplicationRecord
  belongs_to :team
  belongs_to :championship, inverse_of: :enrolled_team_championships
end
