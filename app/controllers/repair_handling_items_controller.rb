class RepairHandlingItemsController < ApplicationController
  
  def extjs_sc_model
   'RepairHandlingItem'
  end 
  
  #tab gestione riparazione
  def rhi_edit
    @item = RepairHandlingItem.find(params[:rec_id])
  end
  
  
  #imposto data di invio preventivo (estimate)
  def set_estimate
    item = RepairHandlingItem.find(params[:rec_id])
     item.estimate_at = Time.zone.now
     item.estimate_user_id = current_user.id
    exe_save(item)
  end

  
  
#richiedo modifica a preventivo (annullo data di estimate)
def req_estimate_modify
  item = RepairHandlingItem.find(params[:rec_id])
   item.estimate_at = nil
   item.estimate_user_id = nil
  exe_save(item)
end
  

#imposto data di autorizzazione preventivo (compagnia)
def set_authorized
     item = RepairHandlingItem.find(params[:rec_id])
      item.estimate_authorized_at = Time.zone.now
      item.estimate_authorized_user_id = current_user.id
     exe_save(item)
end

#riparato
def set_repair_completed
  item = RepairHandlingItem.find(params[:rec_id])
   item.repair_completed_at = Time.zone.now
   item.repair_completed_user_id = current_user.id
  exe_save(item)
end

#ritorno in terminal
def set_out_garage
  item = RepairHandlingItem.find(params[:rec_id])
   item.out_garage_at = Time.zone.now
   item.out_garage_user_id = current_user.id
  exe_save(item)
end



def estimate_edit
  @item = RepairHandlingItem.find(params[:rhi_id])
end

def get_estimate_items
  ret = {}
   rhi = RepairHandlingItem.find(params[:rhi_id])
   ret[:items] = rhi.repair_estimate_items.as_json(RepairEstimateItem.as_json_prop)
   ret[:success] = true
   render json: ret
end

def estimate_new_row  
  @rhi = RepairHandlingItem.find(params[:rhi_id])
  @rei = @rhi.repair_estimate_items.new(
    :repair_processing => RepairProcessing.new(
        :repair_position => RepairPosition.new(),
        :repair_component => RepairComponent.new()
      )
  )
end

def save_rei
  ret = {}  
  @rhi = RepairHandlingItem.find(params[:repair_handling_item_id])
  repair_price = RepairPrice.where("repair_processing_id=?", params[:repair_processing_id]).where("shipowner_id=?", @rhi.handling_item.handling_header.shipowner_id).first  
  n = @rhi.repair_estimate_items.new
   n.repair_processing_id = params[:repair_processing_id]
   n.quantity = params[:quantity].to_s.gsub(',', '.').to_f
   n.side = params[:side]
   n.provider_notes = params[:provider_notes]
   
   n.set_auto_data(repair_price)  
     
  n.save!
  ret[:success] = true
  render json: ret
end


#in base a rhi (da cui prendo shipowner) mostro l'elenco dei positions (con almeno un record a listino)
def get_positions_by_rhi
  rhi = RepairHandlingItem.find(params[:rhi_id])
  ret = {}         
  rps = RepairPosition.joins({:repair_processings => :repair_prices}).where({repair_prices: {shipowner_id: rhi.handling_header.shipowner_id}})
   ret[:items] = rps.as_json(RepairPosition.as_json_prop)
   ret[:success] = true
   render json: ret
end

#in base a rhi (da cui prendo shipowner) mostro l'elenco dei components (con almeno un record in listino)
def get_components_by_rhi
  rhi = RepairHandlingItem.find(params[:rhi_id])
  ret = {}         
  rps = RepairComponent.joins({:repair_processings => :repair_prices})
  rps = rps.where({repair_prices: {shipowner_id: rhi.handling_header.shipowner_id}})
  rps = rps.where({repair_processings: {repair_position_id: params[:flt_repair_position]} })  
   ret[:items] = rps.as_json(RepairComponent.as_json_prop)
   ret[:success] = true
   render json: ret
end


def get_processings_by_rhi
  rhi = RepairHandlingItem.find(params[:rhi_id])
  ret = {}
   rps = RepairPrice.joins(:repair_processing).where("shipowner_id=?", rhi.handling_header.shipowner_id)
   rps = rps.where({repair_processings: {repair_position_id: params[:flt_repair_position]} })
   rps = rps.where({repair_processings: {repair_component_id: params[:flt_repair_component]} })     
   ret[:items] = rps.as_json(RepairPrice.as_json_prop)
   ret[:success] = true
   render json: ret
end




def exe_save(item)
   message = ''
   ActiveRecord::Base.transaction do   
    begin     
       
     item.save!
     
     #se ho concluso tutte le operazioni devo accodare l'operazione 'REPAIR'
     if item.is_all_completed()
       ret_set_close = item.set_close()
       message = ret_set_close[:message]
       raise "Errore su controllo aggiunta dettaglio movimento" if !ret_set_close[:success]
     end

      render json: {:success => true, :message => '',
          :enable_operations=> item.enable_operations_list.as_json, 
          :data=>[item.as_json(extjs_sc_model.constantize.as_json_prop)]}     
     
   rescue => exception
     logger.info exception.backtrace
     to_rollback = true  
      render json: {:success => false, :message => "Errore. Contattare amministratore di sistema (#{message})",
          :enable_operations=> item.enable_operations_list.as_json, 
          :data=>[item.as_json(extjs_sc_model.constantize.as_json_prop)]}     
   end
   raise ActiveRecord::Rollback if to_rollback    
  end #transaction        
end
    
end
