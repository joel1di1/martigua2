class DaysController < InheritedResources::Base
  respond_to :html, :json

  def create
    @day = Day.new day_params
    @day.season = @day.calendar ? @day.calendar.season : Season.current
    @day.save!
    redirect_to referer_url_or(section_days_path(current_section)), notice: 'Journée créée'
  end

  protected
    def day_params
      params.require(:day).permit(:name, :period_start_date, :calendar_id)
    end
end
