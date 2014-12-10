class ImportItemsController < ApplicationController

  def extjs_sc_model
    'ImportItems'
  end


  def import
    ImportItem.import(params[:file])
    redirect_to root_url, notice: "Items imported."
  end
  
  def set_ok
   rec = ImportItem.find(params[:rec_id])
   rec.status = 'OK'
   rec.save!
   ret = {}
   ret[:success] = true
   ret[:data] = rec.as_json()
   render json: ret
  end

  def set_damaged
   rec = ImportItem.find(params[:rec_id])
   rec.status = 'CHECK'
   rec.save!
   ret = {}
   ret[:success] = true
   ret[:data] = rec.as_json()
   render json: ret
  end

end
