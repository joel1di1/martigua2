class SelectionsController < ApplicationController

  def destroy 
    Selection.find(params[:id]).destroy
    redirect_to referer_url_or(root_path)
  end

end
