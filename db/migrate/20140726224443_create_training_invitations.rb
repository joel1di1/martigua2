class CreateTrainingInvitations < ActiveRecord::Migration[4.2]
  def change
    create_table :training_invitations do |t|
      t.belongs_to :training, index: true, null: false

      t.timestamps
    end
  end
end
