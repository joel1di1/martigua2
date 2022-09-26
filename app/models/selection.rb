# frozen_string_literal: true

class Selection < ApplicationRecord
  belongs_to :user
  belongs_to :match
  belongs_to :team

  before_create :destroy_all_selections_for_this_user_for_the_same_day

  validates :user, :match, :team, presence: true

  protected

  def destroy_all_selections_for_this_user_for_the_same_day
    Selection.joins(:match).where(matches: { day: match.day }, user:).destroy_all
  end
end
