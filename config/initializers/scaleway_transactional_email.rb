# frozen_string_literal: true

# Makes `config.action_mailer.delivery_method = :scaleway` usable. Registering here rather
# than in application.rb keeps the delivery class autoloaded like any other service.
ActiveSupport.on_load(:action_mailer) do
  add_delivery_method :scaleway, Scaleway::TransactionalEmailDelivery
end
