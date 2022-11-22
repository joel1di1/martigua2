# frozen_string_literal: true

class ActiveRecordAsyncJob
  include Sidekiq::Job

  # instanciate object and call method
  def perform(class_name, object_id, method, *args)
    Rails.logger.debug { "performing #{class_name}##{method} with args #{args.inspect}" }
    clazz = class_name.constantize
    object = object_id.present? ? clazz.find(object_id) : clazz
    object.send(method, *args)
  end
end
