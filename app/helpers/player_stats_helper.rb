# frozen_string_literal: true

module PlayerStatsHelper
  def sort_link(label, column, current_sort, current_direction)
    is_active = current_sort == column
    new_direction = is_active && current_direction == 'desc' ? 'asc' : 'desc'

    link_params = request.query_parameters.merge(sort: column, direction: new_direction)

    link_to section_player_stats_path(current_section, **link_params),
            class: "group inline-flex items-center gap-1 #{is_active ? 'text-indigo-600' : 'text-gray-900 hover:text-indigo-600'}" do
      concat content_tag(:span, label)
      concat sort_arrow(is_active, current_direction)
    end
  end

  private

  def sort_arrow(active, direction)
    if active
      if direction == 'asc'
        content_tag(:svg, arrow_up_path, xmlns: 'http://www.w3.org/2000/svg', viewBox: '0 0 20 20', fill: 'currentColor',
                                         class: 'w-4 h-4')
      else
        content_tag(:svg, arrow_down_path, xmlns: 'http://www.w3.org/2000/svg', viewBox: '0 0 20 20', fill: 'currentColor',
                                           class: 'w-4 h-4')
      end
    else
      content_tag(:svg, arrows_updown_path, xmlns: 'http://www.w3.org/2000/svg', viewBox: '0 0 20 20', fill: 'currentColor',
                                            class: 'w-4 h-4 text-gray-300 group-hover:text-gray-400')
    end
  end

  def arrow_up_path
    content_tag(:path, nil, 'fill-rule': 'evenodd',
                            d: 'M10 17a.75.75 0 0 1-.75-.75V5.612L5.29 9.77a.75.75 0 0 1-1.08-1.04l5.25-5.5a.75.75 0 0 1 1.08 0l5.25 5.5a.75.75 0 1 1-1.08 1.04l-3.96-4.158V16.25A.75.75 0 0 1 10 17Z',
                            'clip-rule': 'evenodd')
  end

  def arrow_down_path
    content_tag(:path, nil, 'fill-rule': 'evenodd',
                            d: 'M10 3a.75.75 0 0 1 .75.75v10.638l3.96-4.158a.75.75 0 1 1 1.08 1.04l-5.25 5.5a.75.75 0 0 1-1.08 0l-5.25-5.5a.75.75 0 1 1 1.08-1.04l3.96 4.158V3.75A.75.75 0 0 1 10 3Z',
                            'clip-rule': 'evenodd')
  end

  def arrows_updown_path
    d = 'M10 3a.75.75 0 0 1 .55.24l3.25 3.5a.75.75 0 1 1-1.1 1.02L10 4.852 7.3 7.76a.75.75 0 0 1-1.1-1.02l3.25-3.5A.75.75 0 0 1 10 3Z' \
        'm-3.76 9.2a.75.75 0 0 1 1.06.04l2.7 2.908 2.7-2.908a.75.75 0 1 1 1.1 1.02l-3.25 3.5a.75.75 0 0 1-1.1 0l-3.25-3.5a.75.75 0 0 1 .04-1.06Z'
    content_tag(:path, nil, 'fill-rule': 'evenodd', d: d, 'clip-rule': 'evenodd')
  end
end
