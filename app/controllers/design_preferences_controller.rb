# frozen_string_literal: true

class DesignPreferencesController < ApplicationController
  def update
    new_design = ActiveModel::Type::Boolean.new.cast(params.expect(:new_design))
    current_user.update!(new_design:)
    redirect_back_or_to root_path,
                        notice: new_design ? 'Nouveau design activé' : 'Ancien design rétabli'
  end
end
