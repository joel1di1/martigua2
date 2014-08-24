class ClubsController < ApplicationController
  def show
    @club = Club.find(params[:id])
  end
end
