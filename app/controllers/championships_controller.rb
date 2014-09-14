class ChampionshipsController < ApplicationController
  def index 
    @championships = current_section.championships
  end
end
