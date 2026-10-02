# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LegacyTrainingsCleaner do
  let(:section) { create(:section) }
  let(:season) { Season.current }

  describe '.assign_default_section' do
    let!(:orphan) { create(:training) }
    let!(:attached) { create(:training, with_section: create(:section)) }

    it 'attaches trainings without section to the given section' do
      LegacyTrainingsCleaner.assign_default_section(section)
      expect(orphan.reload.sections).to eq [section]
    end

    it 'leaves other trainings alone' do
      expect { LegacyTrainingsCleaner.assign_default_section(section) }.not_to(change { attached.reload.sections.to_a })
    end
  end

  describe '.assign_default_groups' do
    let(:training) { create(:training, with_section: section, start_datetime: season.start_date + 10.days) }
    let(:player) { create(:user, with_section: section) }
    let(:coach) { create(:user, with_section_as_coach: section) }

    before do
      player
      coach
      training
      section.group_every_players.group_trainings.delete_all
    end

    it 'attaches the players group of the training season' do
      LegacyTrainingsCleaner.assign_default_groups
      expect(training.reload.groups).to eq [section.group_every_players(season:)]
    end

    it 'puts the season players, and only them, in the group' do
      LegacyTrainingsCleaner.assign_default_groups
      expect(training.reload.users).to contain_exactly(player)
    end

    it 'uses the next season for trainings between two seasons' do
      create(:season, start_date: Date.new(2010, 9, 1), end_date: Date.new(2011, 7, 1))
      next_season = create(:season, start_date: Date.new(2011, 9, 1), end_date: Date.new(2012, 7, 1))
      gap_training = create(:training, with_section: section, start_datetime: Time.zone.local(2011, 7, 15, 20))
      LegacyTrainingsCleaner.assign_default_groups
      expect(gap_training.reload.groups.first.season).to eq next_season
    end

    it 'does not touch trainings that already have a group' do
      other_group = create(:group, section:)
      grouped = create(:training, with_section: section, with_group: other_group)
      LegacyTrainingsCleaner.assign_default_groups
      expect(grouped.reload.groups).to eq [other_group]
    end
  end

  describe '.purge_non_member_presences' do
    let(:group) { section.group_every_players }
    let(:training) { create(:training, with_section: section, with_group: group) }
    let(:member) { create(:user, with_section: section) }
    let(:outsider) { create(:user) }

    before do
      member.present_for!(training)
      outsider.not_present_for!(training)
    end

    it 'deletes presences of users that are not in the training groups' do
      expect { LegacyTrainingsCleaner.purge_non_member_presences }.to change(TrainingPresence, :count).by(-1)
    end

    it 'keeps presences of members' do
      LegacyTrainingsCleaner.purge_non_member_presences
      expect(member.present_for?(training)).to be true
    end

    it 'keeps presences of trainings without groups' do
      groupless = create(:training, with_section: section)
      outsider.present_for!(groupless)
      expect { LegacyTrainingsCleaner.purge_non_member_presences }.not_to(change { groupless.training_presences.count })
    end
  end
end
