# frozen_string_literal: true

class DutyTask < ApplicationRecord
  TASKS = {
    youth_training: { weight: 12, name: 'Entraînement jeunes' },
    mark_table: { weight: 6, name: 'Faire la table' },
    training_bibs: { weight: 3, name: 'Laver les chasubles' }
  }.freeze

  TASK_NAMES_COLLECTION = TASKS.map { |task_id, hash| [hash[:name], task_id] }

  belongs_to :user, inverse_of: :duty_tasks
  validates :key, :name, :weight, :user, presence: true

  before_validation :set_name_weight_from_key

  protected

  def set_name_weight_from_key
    return if key.blank?

    task_details = TASKS[key.to_sym]
    raise "No details for duty task #{key}" if task_details.blank?

    self.weight ||= task_details[:weight]
    self.name ||= task_details[:name]
  end
end
