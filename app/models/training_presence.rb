# frozen_string_literal: true

class TrainingPresence < ApplicationRecord
  belongs_to :user
  belongs_to :training, inverse_of: :training_presences
end
