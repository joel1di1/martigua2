# frozen_string_literal: true

module ApplicationHelper
  def active_if_current_path(path)
    url_for == path ? 'active' : ''
  end

  def initials(name)
    name.to_s.split(/[\s-]+/).compact_blank.first(2).pluck(0).join.upcase
  end
end
