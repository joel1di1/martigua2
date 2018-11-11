class ScrappedRankingsController < InheritedResources::Base

  private

    def scrapped_ranking_params
      params.require(:scrapped_ranking).permit(:scrapped_content)
    end

end
