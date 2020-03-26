# frozen_string_literal: true

class VisitorsController < ApplicationController
  skip_before_action :authenticate_user!

  def index
    return unless user_signed_in?

    redirect_to section_path(current_user.sections.first) if current_user.sections.size.positive?
  end

  def ping
    map = {
      'hostname' => Socket.gethostname,
      'revision' => revision,
      'app' => 'export_tools',
    }
    render json: map
  end

  protected

  def revision
    File.read(Rails.root.join('REVISION')).strip
  rescue StandardError
    'file-not-found'
  end
end
