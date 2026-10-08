# frozen_string_literal: true

# Opt-in redesign, page by page. A controller calling `offers_new_design` renders its
# `*.html+new_design.slim` templates inside the `app_shell` layout for users who enabled the
# new design, and its regular templates inside the `application` layout for everyone else.
module NewDesign
  extend ActiveSupport::Concern

  VARIANT = :new_design

  included do
    helper_method :new_design?, :new_design_available?
  end

  class_methods do
    def offers_new_design(**)
      before_action(:offer_new_design, **)
      layout :new_design_layout
    end
  end

  private

  def new_design?
    current_user.present? && current_user.new_design?
  end

  def new_design_available?
    @new_design_available.present?
  end

  def offer_new_design
    @new_design_available = true
    request.variant = VARIANT if new_design?
  end

  def new_design_layout
    request.variant.include?(VARIANT) ? 'app_shell' : 'application'
  end
end
