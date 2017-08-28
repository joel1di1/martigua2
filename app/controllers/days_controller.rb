class DaysController < InheritedResources::Base

  protected
    def day_params
      params.require(:day).permit(:name)
    end
end
