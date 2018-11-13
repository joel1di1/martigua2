class ScrappedRankingsController < InheritedResources::Base
  private

  def scrapped_ranking_params
    params.require(:scrapped_ranking).permit(:scrapped_content)
  end

  def collection
    get_collection_ivar || set_collection_ivar(end_of_association_chain.order(:championship_number))
  end
end
