class ChampionshipsController < ApplicationController
  before_action :find_championship_by_id, except: [:index, :new, :create]

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
      if params[:default_team_id].present?
        @championship.enroll_team! Team.find_by_id(params[:default_team_id])
      end

      redirect_to_with additionnal_params: {'match[championship_id]' => @championship.id},
                       fallback: section_championship_path(current_section, @championship),
                       use_referrer: false,
                       notice: 'Compétition créée'
    else
      render :new
    end
  end

  def show
  end

  def edit
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
end
