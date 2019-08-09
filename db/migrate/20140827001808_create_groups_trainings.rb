# frozen_string_literal: true

class CreateGroupsTrainings < ActiveRecord::Migration[4.2]
  def change
    create_table :groups_trainings, id: false do |t|
      t.belongs_to :training, index: true, null: false
      t.belongs_to :group, index: true, null: false
    end
  end
end
