class ChampionshipsController < ApplicationController
  before_action :find_championship_by_id, except: [:index, :new, :create]

  def index
    @championships = current_section ? current_section.championships : Championship.all
    @championships = @championships.select{|c| c.season == Season.current}
  end

  def new
    prepare_form
    @championship = Championship.new championship_params
  end

  def create
    @championship = Championship.new championship_params
    @championship.season = Season.current
    if @championship.save
      redirect_to section_championship_path(current_section, @championship), notice: 'Compétition créée'
    else
      render :new
    end
  end

  def show
  end

  def edit
    prepare_form
  end

  def update
    if @championship.update_attributes(championship_params)
      redirect_to section_championship_path(current_section, @championship), notice: 'Compétition sauvegardée'
    else
      prepare_form
      render :edit
    end
  end

  protected
    def championship_params
      if params[:championship]
        params.require(:championship).permit(:name, :calendar_id)
      else
        {}
      end
    end

    def find_championship_by_id
      @championship = Championship.find params[:id]
    rescue ActiveRecord::RecordNotFound
      handle_404
    end

    def prepare_form
      season = @championship ? @championship.season : Season.current
      @calendars = Calendar.where(season: season)
    end
end
