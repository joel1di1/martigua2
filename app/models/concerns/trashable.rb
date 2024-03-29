# frozen_string_literal: true

module Trashable
  extend ActiveSupport::Concern

  included do
    default_scope { where(deleted_at: nil) }
  end

  module ClassMethods
    def trashed
      unscoped.where(arel_table[:deleted_at].not_eq(nil))
    end
  end

  def trash
    run_callbacks :destroy do
      update_column :deleted_at, Time.zone.now # rubocop:disable Rails/SkipsModelValidations
    end
  end

  def destroy
    trash
  end

  def recover
    # update_column not appropriate here as it uses the default scope
    update_attribute :deleted_at, nil # rubocop:disable Rails/SkipsModelValidations
  end
end
