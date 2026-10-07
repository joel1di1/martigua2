# frozen_string_literal: true

# Display of the answer a player declared for a training (is_present), as opposed to the
# presence validated by a coach (presence_validated).
module TrainingPresencesHelper
  DECLARED_PRESENCES = {
    true => { label: 'A dit présent', background: 'bg-green-200' },
    false => { label: 'A dit absent', background: 'bg-red-200' },
    nil => { label: 'Pas de réponse', background: 'bg-yellow-200' }
  }.freeze

  def declared_presence_label(presence)
    DECLARED_PRESENCES[presence&.is_present][:label]
  end

  def declared_presence_background(presence)
    DECLARED_PRESENCES[presence&.is_present][:background]
  end
end
