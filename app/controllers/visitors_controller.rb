# frozen_string_literal: true

class VisitorsController < ApplicationController
  skip_before_action :authenticate_user!

  def index
    if user_signed_in?
      redirect_to section_path(current_user.sections.first) if current_user.sections.size > 0
    end
  end
end
