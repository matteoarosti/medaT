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
  @rei = @rhi.repair_estimate_items.new
end

def get_processings_by_rhi
  rhi = RepairHandlingItem.find(params[:rhi_id])
  ret = {}
   rps = RepairPrice.where("shipowner_id=?", rhi.handling_header.shipowner_id)
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
