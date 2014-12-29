class TerminalMovsController < ApplicationController

  layout "application_extjs", only: [:index]
  

#ingresso (apertura viewport Extjs)
  def index
  end


#verifico validita' numero container, mostro elenco movimento o voce per crearne uno nuovo
#############################################################
def new_mov_search_handling
#############################################################
 ret = {}
 ret[:items] = []
 
  params[:container_number] = params[:search_number] if params[:search_type] == 'container'
  params[:booking_number]   = params[:search_number] if params[:search_type] == 'booking'  
 
  hhs = HandlingHeader.where('1 = 1')
  hhs = hhs.where('container_number LIKE ?', "%#{params[:container_number]}%") unless params[:container_number].blank?
  hhs = hhs.where('num_booking LIKE ?', "%#{params[:booking_number]}%") unless params[:booking_number].blank?
  if !params[:status].blank? 
    hhs = hhs.where('handling_status = ?', params[:status])
  end
 
 #hhs = HandlingHeader.container(params[:container_number]).order('id').limit(1000)
 
 handling_EDIT_exists = false
 
  hhs.each do |hh|
    if hh.handling_status == 'CLOSE'
     op = 'VIEW'
     op_descr = '[ Visualizza ]'
    else
     handling_EDIT_exists = true    
     op = 'EDIT' 
     op_descr = '[ Modifica ]'
    end
     
    ret[:items] << {
        :handling_id  => hh.id, :num_booking  => hh.num_booking,
        :container_number => hh.container_number, :is_container_editable => false,
        :stato => hh.handling_status, :stato_descr => hh.handling_status, :op => op, :op_descr => op_descr,
        :descr => "Movimento ##{hh.id.to_s}, #{HandlingHeader::TYPES[hh.handling_type]}"
      }
  end
 
 #se non ci sono movimenti aperti, ne propongo uno nuovo (se cercavo per num container)
 if ret[:items].length > 0 && !handling_EDIT_exists && !params[:container_number].blank?
  ret[:items] << {:container_number => params[:container_number], :is_container_editable => false,
        :stato => 'CRT', :stato_descr => '', :descr => 'Crea nuovo movimento per il container richiesto', :op => 'CRT', :op_descr => '[ Crea ]'} 
 end
 
 
 #se non ci sono movimenti aperti, ne propongo uno nuovo con possibilita' di creare container
 if ret[:items].length == 0  && !params[:container_number].blank?
  #verifico il check digiti
  valid_CD = ImportHeader.check_digit(params[:container_number])
  
  ret[:items] << {:container_number => params[:container_number], :is_container_editable => true, :valid_CD => valid_CD,
        :stato => 'CRT', :stato_descr => '', :descr => 'Crea il nuovo container e il nuovo movimento', :op => 'CRT', :op_descr => '[ Crea ]'}
 end
 
 render json: ret
end


  
# scelta tipo operazione per nuovo inserimento  
#############################################################
def add_handling_items_select_type
#############################################################
 @rec_id = params[:rec_id]
 hh = HandlingHeader.find(@rec_id)
 @operations = hh.get_operations()  #elenco operazioni ammesse (per tipo, stato, ...)
end

  
#inserimento nuovo dettaglio movimento
#############################################################
def add_handling_items
#############################################################
 @rec_id = params[:rec_id]
 @op     = params[:op]
 @hh     = HandlingHeader.find(@rec_id)
 @new_rec = @hh.handling_items.new()
 @new_rec.handling_item_type = @op
 @new_rec.datetime_op = Time.now
 render :partial => "add_handling_items_" + @op
end  
  
  
  
end #class
