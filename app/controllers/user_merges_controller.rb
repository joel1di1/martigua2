# frozen_string_literal: true

# Unlisted admin page: turns a parent account into a contact email of their child's account.
# Reachable at /user_merges/new only, by the same admins as the /admin section.
class UserMergesController < ApplicationController
  before_action :authenticate_admin

  def new
    @users = User.order(:last_name, :first_name)
  end

  def create
    source = User.find(merge_params[:source_id])
    target = User.find(merge_params[:target_id])

    UserMergeService.call(source:, target:, label: merge_params[:label])
    redirect_to new_user_merge_path,
                notice: "#{source.email} est maintenant un email de contact de #{target.full_name}, " \
                        'le compte a été supprimé'
  rescue ActiveRecord::RecordNotFound
    redirect_to new_user_merge_path, alert: 'Compte introuvable'
  rescue UserMergeService::Error, ActiveRecord::RecordInvalid, ActiveRecord::InvalidForeignKey => e
    redirect_to new_user_merge_path, alert: e.message
  end

  private

  # Same rule as the /admin section: an AdminUser row matching the signed-in user's email.
  def authenticate_admin
    return if AdminUser.exists?(email: current_user&.email)

    render(file: Rails.public_path.join('403.html'), status: :forbidden, layout: false)
  end

  def merge_params
    @merge_params ||= params.expect(user_merge: %i[source_id target_id label])
  end
end
