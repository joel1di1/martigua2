# frozen_string_literal: true

class EventsController < ApplicationController
  before_action :verify_user_member_of_section

  def index
  end
end
