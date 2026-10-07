# frozen_string_literal: true

module NavigationHelper
  # [title, path, icon] for each entry of the main navigation.
  def main_navigation_links
    return [['Accueil', root_path, :home]] if current_section.blank?

    [
      [current_section.to_s, section_path(current_section), :home],
      ['Membres', section_users_path(current_section), :users],
      ['Entrainements', section_trainings_path(current_section), :calendar],
      (['Équipes', section_teams_path(current_section), :user_group] if can_see_teams?),
      ['Groupes', section_groups_path(current_section), :rectangle_group],
      ['Compétitions', section_championships_path(current_section), :trophy],
      ['Stats', section_player_stats_path(current_section), :chart_bar],
      ['Chats', section_channels_path(current_section), :chat_bubble_left_right],
      ['Tigs', section_duty_tasks_path(current_section), :clipboard_document_check]
    ].compact
  end

  def navigation_link_current?(path)
    return request.path == path if current_section.blank? || path == section_path(current_section)

    request.path == path || request.path.start_with?("#{path}/")
  end

  private

  def can_see_teams?
    current_user.coach_of?(current_section) || current_user.admin_of?(current_section.club) ||
      current_user.super_admin?
  end
end
