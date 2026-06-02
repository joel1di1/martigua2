# frozen_string_literal: true

class ClubsController < ApplicationController
  def show
    @club = Club.find(params.expect(:id))
  end
end
