# frozen_string_literal: true

class ContactEmailsController < ApplicationController
  before_action :set_user
  before_action :verify_can_edit_user
  before_action :set_contact_email, only: :destroy

  def create
    @contact_email = @user.contact_emails.new(contact_email_params)

    if @contact_email.save
      redirect_with fallback: edit_user_path_for_user, notice: 'Email de contact ajouté'
    else
      redirect_with fallback: edit_user_path_for_user, alert: @contact_email.errors.full_messages.to_sentence
    end
  end

  def destroy
    @contact_email.destroy!
    redirect_with fallback: edit_user_path_for_user, notice: 'Email de contact supprimé'
  end

  private

  def set_user
    id = params.expect(:user_id)
    @user = current_section.present? ? current_section.users.find(id) : User.find(id)
  rescue ActiveRecord::RecordNotFound
    catch404
  end

  # Same rule as UsersController#update: your own profile, or a coach of the section.
  def verify_can_edit_user
    return if @user == current_user || current_user.coach_of?(current_section)

    render(file: Rails.public_path.join('403.html'), status: :forbidden, layout: false)
  end

  def set_contact_email
    @contact_email = @user.contact_emails.find(params.expect(:id))
  rescue ActiveRecord::RecordNotFound
    catch404
  end

  def edit_user_path_for_user
    current_section.present? ? edit_section_user_path(current_section, @user) : edit_user_path(@user)
  end

  def contact_email_params
    params.expect(user_contact_email: %i[email label])
  end
end
