# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PrefetchTrainingData do
  subject(:controller) do
    Class.new do
      include PrefetchTrainingData

      attr_reader :nb_presents, :nb_not_presents, :nb_no_response
    end.new
  end

  let(:section) { create(:section) }
  let(:group) { section.group_every_players }
  let(:training) { create(:training, with_section: section, with_group: group) }
  let(:player) { create(:user, with_section: section) }
  let(:absent_player) { create(:user, with_section: section) }
  let(:outsider) { create(:user) }

  before do
    create(:user, with_section: section) # has not answered
    player.present_for!(training)
    absent_player.not_present_for!(training)
    outsider.present_for!(training)
    create(:user).not_present_for!(training)
    controller.add_training_prefetch_data([training])
  end

  it { expect(controller.nb_presents[training]).to eq 1 }
  it { expect(controller.nb_not_presents[training]).to eq 1 }
  it { expect(controller.nb_no_response[training]).to eq 1 }
end
