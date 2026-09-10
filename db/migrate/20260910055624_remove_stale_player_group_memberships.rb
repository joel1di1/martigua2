# frozen_string_literal: true

class RemoveStalePlayerGroupMemberships < ActiveRecord::Migration[8.1]
  def up
    Group.where(system: true, role: 'every_players').find_each do |group|
      valid_user_ids = Participation.where(section_id: group.section_id, season_id: group.season_id,
                                           role: Participation::PLAYER).pluck(:user_id)
      GroupMembership.where(group_id: group.id).where.not(user_id: valid_user_ids).delete_all
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
