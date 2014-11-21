class TerminalMovsController < ApplicationController

  layout "application_extjs", only: [:index]
  

#ingresso (apertura viewport Extjs)
  def index
  end


#verifico validita' numero container, mostro elenco movimento o voce per crearne uno nuovo
#############################################################
def new_mov_search_container_number
#############################################################
 ret = {}
 ret[:items] = []
 hhs = HandlingHeader.container(params[:container_number]).order('id').limit(1000)
 hhs.each do |hh|
  ret[:items] << hh
 end
 
 if ret[:items].length == 0
  ret[:items] << {:container_number => params[:container_number], 
        :stato => 'CRT', :stato_descr => '', :descr => 'Nuovo movimento', :op => 'NEW', :op_descr => '[ Crea ]'}
 end
 
 render json: ret
end


  
# scelta tipo operazione per nuovo inserimento  
#############################################################
def add_handling_items_select_type
#############################################################
 @rec_id = params[:rec_id]
end
  
#inserimento nuovo dettaglio movimento
#############################################################
def add_handling_items
#############################################################
 @rec_id = params[:rec_id]
 @op     = params[:op]
 @new_rec = HandlingHeader.find(@rec_id).handling_items.new()
 render :partial => "add_handling_items_" + @op
end  
  
  
  
end #class
