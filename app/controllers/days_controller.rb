class DaysController < ApplicationController

  respond_to :html, :json

  def update
    @day = Day.find(params[:id])

    respond_to do |format|
      if @day.update_attributes(day_params)
        format.html { redirect_to(@day, :notice => 'Journée mise à jour.') }
        format.json { respond_with_bip(@day) }
      else
        format.html { render :action => "edit" }
        format.json { respond_with_bip(@day) }
      end
    end
  end

  protected
    def day_params
      if params[:day]
        params.require(:day).permit(:name)
      else
        {}
      end
    end

end
