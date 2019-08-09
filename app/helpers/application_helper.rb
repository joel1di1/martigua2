# frozen_string_literal: true

module ApplicationHelper
  def active_if_current_path(path)
    url_for == path ? 'active' : ''
  end
end
