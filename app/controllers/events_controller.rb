# frozen_string_literal: true

class EventsController < ApplicationController
  before_action :verify_user_member_of_section

  def index
    @events = current_section.next_events
  end
end
