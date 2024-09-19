# frozen_string_literal: true

class DaysController < ApplicationController
  respond_to :html, :json

  def new
    @day = Day.new
  end

  def create
    @day = Day.new day_params
    @day.save!

    redirect_with(fallback: section_days_path(current_section),
                  additionnal_params: { 'match[day_id]' => @day.id },
                  notice: 'Journée créée')
  end

  def update
    @day = Day.find(params[:id])
    @day.update!(selection_hidden: params[:selection_hidden])

    redirect_to section_day_selections_path(current_section, @day)
  end

  protected

  def day_params
    params.require(:day).permit(:name, :period_start_date, :calendar_id)
  end
end
