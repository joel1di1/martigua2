# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  # respond to methods starting with 'async_' by sending them to a background job
  def method_missing(method, *args, &block)
    if method.to_s.start_with?('async_')
      raise 'async jobs with block are not supported' if block.present?

      ActiveRecordAsyncJob.perform_async(self.class.name, id, method.to_s.sub('async_', ''), *args)
    else
      super
    end
  end

  def respond_to_missing?(method, include_private = false)
    method.to_s.start_with?('async_') || super
  end

  def self.method_missing(method, *args, &block)
    if method.to_s.start_with?('async_')
      raise 'async jobs with block are not supported' if block.present?

      ActiveRecordAsyncJob.perform_async(self.name, nil, method.to_s.sub('async_', ''), *args)
    else
      super
    end
  end

  def self.respond_to_missing?(method, include_private = false)
    method.to_s.start_with?('async_') || super
  end
end
