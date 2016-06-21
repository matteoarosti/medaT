class RepairHandlingItemsController < ApplicationController
  
  layout "application_report", only: [:print_estimate, :repair_report_analytic]
        
  def extjs_sc_model
   'RepairHandlingItem'
  end 
  
  #tab gestione riparazione
  def rhi_edit
    if !params[:rec_id].nil? && !params[:rec_id].to_s.empty?
      @item = RepairHandlingItem.find(params[:rec_id])
    else
      @item = RepairHandlingItem.find_by_handling_item_id(params[:handling_item_id])
    end
  end
  
  
  #imposto data di redazione preventivo (estimate)
  def set_estimate
    item = RepairHandlingItem.find(params[:rec_id])
     item.estimate_at = Time.zone.now
     item.estimate_user_id = current_user.id
     
     item.calculate_total_on_estimate
     
    exe_save(item)
  end


  #imposto data di invio preventivo compagnia
  def set_estimate_sent
    item = RepairHandlingItem.find(params[:rec_id])
     item.estimate_sent_at = Time.zone.now
     item.estimate_sent_user_id = current_user.id
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
      
      item.calculate_total_on_authorized      
      
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


  def estimate_edit_row  
    @rhi = RepairHandlingItem.find(params[:rhi_id])
    @rei = @rhi.repair_estimate_items.find(params[:rhi_row_id])
    @edit_row = true
    render "estimate_new_row"
  end


 #in autorizzazione: annulla riga
 def estimate_cancel_row
    ret = {}
    @rhi = RepairEstimateItem.find(params[:data][:rhi_id])
    @rhi.confirmed = false
    @rhi.authorization_notes = params[:data][:authorization_notes] unless params[:data][:authorization_notes].to_s.empty? 
    @rhi.save!
    ret[:data] = @rhi
    ret[:success] = true
    render json: ret    
  end



def save_rei
  ret = {}  
  @rhi = RepairHandlingItem.find(params[:repair_handling_item_id])
  repair_price = RepairPrice.where("repair_processing_id=?", params[:repair_processing_id]).where("shipowner_id=?", @rhi.handling_item.handling_header.shipowner_id).first
  
  if params[:id].empty?      
    n = @rhi.repair_estimate_items.new
    
    #memorizzo i costo orari
    n.provider_hourly_cost = @rhi.handling_item.handling_header.shipowner.estimate_hourly_cost_provider
    n.customer_hourly_cost = @rhi.handling_item.handling_header.shipowner.estimate_hourly_cost_customer
  else
    n = @rhi.repair_estimate_items.find(params[:id])
  end
    
   n.repair_processing_id = params[:repair_processing_id]
   n.quantity = params[:quantity].to_s.gsub(',', '.').to_f
   n.side = params[:side]
   n.provider_notes = params[:provider_notes]
   
   n.set_auto_data(repair_price)  
     
  n.save!
  ret[:success] = true
  render json: ret
end



  def destroy_rei
    ret = {}  
    @rhi = RepairHandlingItem.find(params[:repair_handling_item_id])
    n = @rhi.repair_estimate_items.find(params[:id]).destroy
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
    



#VISTE PERSONALIZZATE  
   

#note
def edit_notes
  @item = RepairHandlingItem.find(params['rec_id'])
  @note_field = params['note_field']
  @datetime_field = params['datetime_field']
end

################################################
def edit_notes_save
################################################
  item = RepairHandlingItem.find(params[:data][:id])
  params[:data].permit!


  if params[:data].has_key?(:in_garage_at_date)
    if params[:data][:in_garage_at_date].empty?
     params[:data][:in_garage_at] = nil 
    else       
     params[:data][:in_garage_at] = generate_datetime(params[:data][:in_garage_at_date], params[:data][:in_garage_at_time])
    end 
    params[:data].delete(:in_garage_at_date)
    params[:data].delete(:in_garage_at_time)
  end    

        
  if params[:data].has_key?(:estimate_at_date)
    if params[:data][:estimate_at_date].empty?
     params[:data][:estimate_at] = nil 
    else       
     params[:data][:estimate_at] = generate_datetime(params[:data][:estimate_at_date], params[:data][:estimate_at_time])
    end 
    params[:data].delete(:estimate_at_date)
    params[:data].delete(:estimate_at_time)
  end    

  if params[:data].has_key?(:estimate_sent_at_date)
    if params[:data][:estimate_sent_at_date].empty?
     params[:data][:estimate_sent_at] = nil 
    else       
     params[:data][:estimate_sent_at] = generate_datetime(params[:data][:estimate_sent_at_date], params[:data][:estimate_sent_at_time])
    end 
    params[:data].delete(:estimate_sent_at_date)
    params[:data].delete(:estimate_sent_at_time)
  end    

  if params[:data].has_key?(:estimate_authorized_at_date)
    if params[:data][:estimate_authorized_at_date].empty?
     params[:data][:estimate_authorized_at] = nil 
    else       
     params[:data][:estimate_authorized_at] = generate_datetime(params[:data][:estimate_authorized_at_date], params[:data][:estimate_authorized_at_time])
    end 
    params[:data].delete(:estimate_authorized_at_date)
    params[:data].delete(:estimate_authorized_at_time)
  end    

  if params[:data].has_key?(:repair_completed_at_date)
    if params[:data][:repair_completed_at_date].empty?
     params[:data][:repair_completed_at] = nil 
    else       
     params[:data][:repair_completed_at] = generate_datetime(params[:data][:repair_completed_at_date], params[:data][:repair_completed_at_time])
    end 
    params[:data].delete(:repair_completed_at_date)
    params[:data].delete(:repair_completed_at_time)
  end    

  if params[:data].has_key?(:out_garage_at_date)
    if params[:data][:out_garage_at_date].empty?
     params[:data][:out_garage_at] = nil 
    else       
     params[:data][:out_garage_at] = generate_datetime(params[:data][:out_garage_at_date], params[:data][:out_garage_at_time])
    end 
    params[:data].delete(:out_garage_at_date)
    params[:data].delete(:out_garage_at_time)
  end    
  
        
  #filtro solo gli attributi presenti nel model e salvo
  item.update(params[:data])
  item.save!()
 
  render json: {:success => true, :message => '', :rhi=>[item.as_json(RepairHandlingItem.as_json_prop)]}    
    
end





##################################################
 def repairs_list
##################################################  
   render :partial=>"repairs_list", :locals => {:filtered_type => params[:filtered_type] }
 end

##################################################
 def get_row_by_filtered_type
##################################################
   
   items = RepairHandlingItem.where('repair_status=?', 'OPEN')
   items = items.joins(:handling_header)
        
   case params[:filtered_type]
          
     
     when 'TO_ESTIMATE'
       items = items.where('estimate_at IS NULL')
     when 'TO_SENT'
       items = items.where('estimate_at IS NOT NULL AND estimate_sent_at IS NULL')
     when 'TO_AUTHORIZED'
            items = items.where('estimate_sent_at IS NOT NULL AND estimate_authorized_at IS NULL')
     when 'TO_REPAIR'
                 items = items.where('estimate_at IS NOT NULL AND repair_completed_at IS NULL')
     when 'TO_OUT_GARAGE'
                      items = items.where('repair_completed_at IS NOT NULL AND out_garage_at IS NULL')

       
            
   end #case
   
   if !params[:form_user][:flt_num_container].to_s.empty?
     items = items.where("handling_headers.container_number LIKE ?", "%#{params[:form_user][:flt_num_container].upcase}%")
   end
   
   render json: items.limit(2000).as_json(RepairHandlingItem.as_json_prop)
 
 end 
 


 def print_estimate_open_params
   @item = RepairHandlingItem.find(params[:rhi_id])
 end 

 def print_estimate
  @item = RepairHandlingItem.find(params[:rhi_id])
 end 
 
 def repair_report_parameters
  @hh = HandlingHeader.new
  @hi = HandlingItem.new
 end
 

end
