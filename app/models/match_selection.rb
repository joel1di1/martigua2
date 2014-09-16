class MatchSelection < ActiveRecord::Base
  belongs_to :match
  belongs_to :team
  belongs_to :user
end
