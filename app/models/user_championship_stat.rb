# frozen_string_literal: true

class UserChampionshipStat < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :championship

  def full_name
    "#{first_name} #{last_name}"
  end
end
