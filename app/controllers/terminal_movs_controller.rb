class TerminalMovsController < ApplicationController

  layout "application_extjs", only: [:index]
  

#ingresso (apertura viewport Extjs)
  def index
  end


#da form per nuovo movimento: verifico validita' numero container, esistenza movimento aperto
def new_mov_search_container_number
 ret = {}
 ret[:items] = []
 hhs = HandlingHeaders.container(params[:container_number]).order('id').limit(1000)
 hhs.each do |hh|
  ret[:items] << hh
 end
 
 if ret[:items].length == 0
  ret[:items] << {:container_number => params[:container_number], 
        :stato => 'CRT', :stato_descr => '', :descr => 'Nuovo movimento', :op => 'NEW', :op_descr => '[ Crea ]'}
 end
 
 render json: ret
end


  
end
