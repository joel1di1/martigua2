# frozen_string_literal: true

class VisitorsController < ApplicationController
  skip_before_action :authenticate_user!

  def index
    return unless user_signed_in?

    redirect_to section_path(current_user.sections.first) if current_user.sections.size.positive?
  end

  protected

  def revision
    Rails.root.join('REVISION').read.strip
  rescue StandardError
    'file-not-found'
  end
end
