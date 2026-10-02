# frozen_string_literal: true

module PrefetchTrainingData
  def add_training_prefetch_data(trainings)
    presences = TrainingPresence.where(training: trainings).members_of_training_groups
    @nb_presents = presences.where(is_present: true).group(:training).count
    @nb_not_presents = presences.where(is_present: false).group(:training).count
    @nb_no_response = trainings.index_with do |training|
      training.users.count - (@nb_presents[training] || 0) - (@nb_not_presents[training] || 0)
    end
  end
end
