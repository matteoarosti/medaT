class ImportItemsController < ApplicationController

  def extjs_sc_model
    'ImportItems'
  end


  def import
    ImportItem.import(params[:file])
    redirect_to root_url, notice: "Items imported."
  end

end
