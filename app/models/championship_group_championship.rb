# frozen_string_literal: true

class ChampionshipGroupChampionship < ApplicationRecord
  belongs_to :championship
  belongs_to :championship_group
end
