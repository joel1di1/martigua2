# frozen_string_literal: true

class AddLastLinkSentAtToUserContactEmails < ActiveRecord::Migration[8.1]
  def change
    add_column :user_contact_emails, :last_link_sent_at, :datetime
  end
end
