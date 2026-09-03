# frozen_string_literal: true

# Unlisted page: turns a parent account into a contact email of their child's account.
# Reachable at /sections/:section_id/user_merges/new only, by the coachs of that section and
# by the admins of the /admin section, and only for two members of that section.
class UserMergesController < ApplicationController
  # Admins are not necessarily members of the section they are cleaning up.
  skip_before_action :verify_user_member_of_section
  before_action :verify_can_merge

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

  def section_users
    current_section.members.order(:last_name, :first_name)
  end

  # The coachs of the section, plus the admins of the /admin section, whose rule is an
  # AdminUser row matching the signed-in user's email.
  def verify_can_merge
    return if current_user&.coach_of?(current_section)
    return if AdminUser.exists?(email: current_user&.email)

    render(file: Rails.public_path.join('403.html'), status: :forbidden, layout: false)
  end

  def merge_params
    @merge_params ||= params.expect(user_merge: %i[source_id target_id label])
  end
end
