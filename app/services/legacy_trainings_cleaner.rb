# frozen_string_literal: true

# One-off data fixes for trainings that predate the group/section model.
module LegacyTrainingsCleaner
  module_function

  def assign_default_section(section)
    trainings = Training.where.missing(:section_trainings).to_a
    trainings.each { |training| training.sections << section }
    trainings.size
  end

  def assign_default_groups
    trainings = Training.where.missing(:group_trainings).joins(:sections).distinct.includes(:sections).to_a
    trainings.each do |training|
      season = season_for(training.start_datetime)
      training.sections.each { |section| training.groups << players_group(section, season) }
    end
    trainings.size
  end

  def purge_non_member_presences
    TrainingPresence.non_members_of_training_groups
                    .where(training_id: GroupTraining.select(:training_id))
                    .delete_all
  end

  # Season containing the date, or the next one for dates between two seasons.
  def season_for(datetime)
    date = datetime.to_date
    Season.where(start_date: ..date, end_date: date...).first ||
      Season.where(start_date: date..).order(:start_date).first ||
      Season.current
  end

  def players_group(section, season)
    group = section.group_every_players(season:)
    player_ids = section.participations.where(season:, role: Participation::PLAYER).pluck(:user_id)
    (player_ids - group.user_ids).each { |user_id| group.group_memberships.create!(user_id:) }
    group
  end
end
