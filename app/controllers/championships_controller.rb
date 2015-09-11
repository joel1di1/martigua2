class ChampionshipsController < ApplicationController
  before_filter :find_championship_by_id, except: [:index, :new, :create]

  def index 
    @championships = current_section ? current_section.championships : Championship.all
    @championships = @championships.select{|c| c.season == Season.current}
  end

  def new
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

  protected
    def championship_params
      if params[:championship]
        params.require(:championship).permit(:name)
      else
        {}
      end
    end

    def find_championship_by_id
      @championship = Championship.find params[:id]
    rescue ActiveRecord::RecordNotFound
      handle_404
    end
end
