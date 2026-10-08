# frozen_string_literal: true

module GroupsHelper
  ROLE_LABELS = { Participation::COACH => 'Coach', Participation::PLAYER => 'Joueur' }.freeze
  BADGE_COLORS = {
    gray: 'bg-gray-100 text-gray-600 fill-gray-400',
    indigo: 'bg-indigo-100 text-indigo-700 fill-indigo-500',
    green: 'bg-green-100 text-green-700 fill-green-500',
    red: 'bg-red-100 text-red-700 fill-red-500'
  }.freeze
  HEX_COLOR = /\A#\h{6}\z/

  # Flat pill with dot, see docs/tailwindplus-snippets/badges/flat-pill-with-dot.html
  def pill_badge(label, color: :gray)
    tag.span(class: "inline-flex items-center gap-x-1.5 rounded-full px-2 py-1 text-xs font-medium #{BADGE_COLORS.fetch(color)}") do
      tag.svg(viewBox: '0 0 6 6', 'aria-hidden': 'true', class: 'size-1.5') { tag.circle(r: 3, cx: 3, cy: 3) } + label
    end
  end

  def group_swatch_style(group)
    color = group.color.to_s
    return '' unless color.match?(HEX_COLOR)

    "background-color: #{color}; color: #{light_color?(color) ? '#111827' : '#ffffff'}"
  end

  def member_roles(user, section)
    season_id = (@member_roles_season ||= Season.current).id
    user.participations
        .select { |participation| participation.section_id == section.id && participation.season_id == season_id }
        .map(&:role).uniq.sort
  end

  def role_badge(role)
    pill_badge(ROLE_LABELS.fetch(role, role.to_s.humanize), color: role == Participation::COACH ? :indigo : :gray)
  end

  private

  def light_color?(hex)
    red, green, blue = hex.delete('#').scan(/../).map { |component| component.to_i(16) }
    ((0.299 * red) + (0.587 * green) + (0.114 * blue)) > 160
  end
end
