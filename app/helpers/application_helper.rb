# frozen_string_literal: true

module ApplicationHelper
  def initials(name)
    name.to_s.split(/[\s-]+/).compact_blank.first(2).pluck(0).join.upcase
  end
end
