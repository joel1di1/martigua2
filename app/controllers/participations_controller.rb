# frozen_string_literal: true

class ParticipationsController < ApplicationController
  before_action :verify_user_member_of_section

  def update
    participation = Participation.find(params.expect(:id))

    participation.update!(main_position: params.dig(:participation, :main_position).presence) if current_user.coach_of?(current_section) && participation.section == current_section

    render partial: 'player_stats/position_form', locals: { participation: participation }
  end
end
