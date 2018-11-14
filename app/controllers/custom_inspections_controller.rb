class CustomInspectionsController < ApplicationController


  #inserimento nuova richiesta
  def new_request
    render :partial => "new_request"
  end
    
     
  
  
  
  
  def graph_data_movs_by_hours       
    render json: ret
  end
  
  
end #class
