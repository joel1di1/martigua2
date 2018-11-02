class Selection < ActiveRecord::Base
  belongs_to :user
  belongs_to :match
  belongs_to :team

  before_create :destroy_all_selections_for_this_user_for_the_same_day

  validates_presence_of :user, :team, :match

  protected

    def destroy_all_selections_for_this_user_for_the_same_day
      Selection.joins(:match).where(matches: {day: match.day}, user: user).destroy_all
    end
end
