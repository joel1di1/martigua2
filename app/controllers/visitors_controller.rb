# frozen_string_literal: true

class VisitorsController < ApplicationController
  skip_before_action :authenticate_user!

  def index
    return unless user_signed_in?

    redirect_to section_path(current_user.sections.first) if current_user.sections.size.positive?
  end

  def letsencrypt
    render plain: '4k3hP8fSRgCKf0inS8qYK9LYs8sU10ZMfSiYs8-Mcxg.BTYdv57u7ZQZV2-xtz9RMKzPSPMl8x8_iPbXUnsskWk'
  end

end
