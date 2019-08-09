# frozen_string_literal: true

module Starburst
  Announcement.class_eval do
    scope :unread_by, lambda { |current_user|
      joins(sanitize_sql_for_conditions([
        "LEFT JOIN starburst_announcement_views ON
                starburst_announcement_views.announcement_id = starburst_announcements.id AND
                starburst_announcement_views.user_id = ?", current_user.id,
      ])).
        where("starburst_announcement_views.announcement_id IS NULL AND starburst_announcement_views.user_id IS NULL")
    }
  end
end
