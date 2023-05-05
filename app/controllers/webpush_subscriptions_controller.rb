# frozen_string_literal: true

class WebpushSubscriptionsController < ApplicationController
  def create
    # Remplacez `current_user` par la méthode que vous utilisez pour récupérer l'utilisateur actuel
    webpush_subscription = current_user.webpush_subscriptions.find_or_create_by(webpush_subscription_params)

    if webpush_subscription.save
      render json: { success: true }, status: :created
    else
      render json: { errors: webpush_subscription.errors }, status: :unprocessable_entity
    end
  end

  private

  def webpush_subscription_params
    params.require(:webpush_subscription).permit(:endpoint, :p256dh_key, :auth_key)
  end
end
