# frozen_string_literal: true

# Unlisted admin page: turns a parent account into a contact email of their child's account.
# Reachable at /sections/:section_id/user_merges/new only, by the same admins as the /admin
# section, and only for two accounts of that section.
class UserMergesController < ApplicationController
  # Admins are not necessarily members of the section they are cleaning up.
  skip_before_action :verify_user_member_of_section
  before_action :authenticate_admin

  def new
    @users = section_users
  end

  def create
    source = section_users.find(merge_params[:source_id])
    target = section_users.find(merge_params[:target_id])

    UserMergeService.call(source:, target:, label: merge_params[:label])
    redirect_to new_section_user_merge_path(current_section),
                notice: "#{source.email} est maintenant un email de contact de #{target.full_name}, " \
                        'le compte a été supprimé'
  rescue ActiveRecord::RecordNotFound
    redirect_to new_section_user_merge_path(current_section), alert: 'Compte introuvable dans cette section'
  rescue UserMergeService::Error, ActiveRecord::RecordInvalid, ActiveRecord::InvalidForeignKey => e
    redirect_to new_section_user_merge_path(current_section), alert: e.message
  end

  private

  # Every account that ever took part in the section, not just this season's: the parent
  # accounts to fold in are usually old ones that were never renewed.
  def section_users
    current_section.users.order(:last_name, :first_name)
  end

  # Same rule as the /admin section: an AdminUser row matching the signed-in user's email.
  def authenticate_admin
    return if AdminUser.exists?(email: current_user&.email)

    render(file: Rails.public_path.join('403.html'), status: :forbidden, layout: false)
  end

  def merge_params
    @merge_params ||= params.expect(user_merge: %i[source_id target_id label])
  end
end
