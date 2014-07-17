class VisitorsController < ApplicationController
  
  skip_before_filter :authenticate_user!

  def index
    if user_signed_in?
      if current_user.has_only_one_section?
        redirect_to section_path(current_user.sections.first)
      end
    end
  end
end
