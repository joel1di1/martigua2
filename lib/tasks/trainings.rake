# frozen_string_literal: true

namespace :trainings do
  desc 'Attach trainings without section to a section (SECTION_ID, default 1)'
  task assign_legacy_sections: :environment do
    section = Section.find(ENV.fetch('SECTION_ID', 1))
    count = LegacyTrainingsCleaner.assign_default_section(section)
    puts "#{count} training(s) attached to #{section.name}"
  end

  desc 'Attach the season players group to trainings without group'
  task assign_legacy_groups: :environment do
    count = LegacyTrainingsCleaner.assign_default_groups
    puts "#{count} training(s) attached to a players group"
  end

  desc 'Delete presences of users that are not in the training groups'
  task purge_non_member_presences: :environment do
    count = LegacyTrainingsCleaner.purge_non_member_presences
    puts "#{count} presence(s) deleted"
  end

  desc 'Run all legacy training fixes in order'
  task fix_legacy_data: %i[assign_legacy_sections assign_legacy_groups purge_non_member_presences]
end
