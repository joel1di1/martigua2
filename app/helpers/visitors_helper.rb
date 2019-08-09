# frozen_string_literal: true

module VisitorsHelper
  def resource_name
    :user
  end

  def resource
    @resource ||= User.new
  end
end
