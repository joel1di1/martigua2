# frozen_string_literal: true

module PrefetchTrainingData
  def add_training_prefetch_data(trainings)
    # `SELECT "training_presences".* FROM "training_presences" WHERE "training_presences"."training_id" = $1 AND "training_presences"."is_present" = $2;`
    @nb_presents = TrainingPresence.where(training: trainings, is_present: true).group(:training).count
    @nb_not_presents = TrainingPresence.where(training: trainings, is_present: false).group(:training).count
    @nb_no_response = trainings.index_with do |training|
      training.users.count - (@nb_presents[training] || 0) - (@nb_not_presents[training] || 0)
    end
  end
end
