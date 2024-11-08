# frozen_string_literal: true

class EventsController < ApplicationController
  before_action :verify_user_member_of_section

  def index
    start_date = params[:start_date].present? ? Date.parse(params[:start_date]) : Time.zone.today
    end_date = start_date + 7.days

    @events = current_section.next_events(start_date: start_date, end_date: end_date)
    @next_date = start_date + 7.days

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end
end
