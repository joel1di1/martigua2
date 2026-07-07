# frozen_string_literal: true

class ChampionshipFfhbImportsController < ApplicationController
  def new
    @championship = Championship.new
    @import_form = Ffhb::ImportForm.new(params)
    @calendars = current_section.season_calendars if @import_form.teams.present?
  end

  def create
    import_form = Ffhb::ImportForm.new(params)
    if import_form.complete? && params[:team_links].present?
      @championship = Championship.create_from_ffhb!(**import_form.to_params, team_links: team_links_params,
                                                                              linked_calendar:)
      redirect_with additionnal_params: { 'match[championship_id]' => @championship.id },
                    fallback: section_championship_path(current_section, @championship),
                    use_referrer: false,
                    notice: 'Compétition créée'
    else
      redirect_to new_section_championship_ffhb_import_path(current_section, params: import_form.to_params)
    end
  end

  private

  def linked_calendar
    return if params[:championship].blank? || params[:championship][:calendar].blank?

    current_section.season_calendars.find(params.expect(championship: [:calendar])[:calendar])
  end

  # team_links maps FFHB team ids (dynamic keys) to local team ids.
  # Keys can't be enumerated, so restrict values instead: scalar strings only,
  # and any linked team must belong to the current section.
  def team_links_params
    links = params.expect(team_links: {}).to_h.select { |_ffhb_team_id, team_id| team_id.is_a?(String) }
    allowed_team_ids = current_section.teams.where(id: links.values.compact_blank).ids.map(&:to_s)
    links.select { |_ffhb_team_id, team_id| team_id.blank? || allowed_team_ids.include?(team_id) }
  end
end
