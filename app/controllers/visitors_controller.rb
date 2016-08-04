class VisitorsController < ApplicationController

  skip_before_action :authenticate_user!

  def index
    if user_signed_in?
      if current_user.sections.size > 0
        redirect_to section_path(current_user.sections.first)
      end
    end
  end
end
