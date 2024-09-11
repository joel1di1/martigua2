# frozen_string_literal: true

json.array! @absences, partial: 'absences/absence', as: :absence
