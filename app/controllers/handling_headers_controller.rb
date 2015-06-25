class HandlingHeadersController < ApplicationController

 def extjs_sc_model
  'HandlingHeader'
 end 


##################################################
def sc_create  #OVERRIDE DEL METODO STANDARD
##################################################
  
    #verifico che non ci sia gia un handling aperto (non CLOSE)
    verify_can_create_new = extjs_sc_model.constantize.verify_can_create_new(params[:data][:container_number])
    if verify_can_create_new == false
      render json: {:success => false, :message=>"Esiste gia' un movimento aperto per questo container"}
      return false
    end
  
    item = extjs_sc_model.constantize.new()    
    params[:data].permit!
    #filtro solo gli attributi presenti nel model e salvo
    create_params = params[:data].select{|k,v| extjs_sc_model.constantize.column_names.include? k}
    create_params[:handling_status] = 'NEW'
    item.update(create_params)
    item.save!()
    render json: {:success => true, :data=>[item.as_json(extjs_sc_model.constantize.as_json_prop)]}
end





# Visualizzazione grid dettagli
##################################################
def hitems_sc_list  
##################################################
  ret = {}
   ret[:items] = HandlingItem.handlingHeader(params[:handling_id]).limit(1000).as_json(HandlingItem.as_json_prop)
   ret[:success] = true
   render json: ret 
end


# Inserimento dettaglio movimento
##################################################
def hitems_sc_create  
##################################################
  
  
  #per evitare anomalia carrier_id = 0 oppure ship_id = 0
  if (
      (!params[:data][:carrier_id].to_s.strip.empty? && params[:data][:carrier_id].to_i == 0) ||
      (!params[:data][:ship_id].to_s.strip.empty? && params[:data][:ship_id].to_i == 0)
      )
    render json: {:success => false, :message => "Attenzione: verificare correttamente i dati inseriti nei campi select"}
    return
  end
  
  
  
   hh = HandlingHeader.find(params[:data][:handling_header_id])
   hi = hh.handling_items.new()
   
   if !params[:data][:datetime_op_date].to_s.empty? && !params[:data][:datetime_op_time].to_s.empty?
     #datetime_op (data e ora) lo trasformo in datetime
     params[:data][:datetime_op] = generate_datetime(params[:data][:datetime_op_date], params[:data][:datetime_op_time]) 
     params[:data].delete(:datetime_op_date)
     params[:data].delete(:datetime_op_time)
   else
     params[:data][:datetime_op] = Time.zone.now
   end
   
   #sposto i valori passati per impostare i dati in testata (tutti quelli che iniziano per hh_)
   hh_filtered_params = params[:data].select{|k,v| k[0..2].to_s == 'hh_'}
   hh_params = {}
   for k_hh_p, hh_p in hh_filtered_params
    params[:data].delete(k_hh_p)
    hh_params["#{k_hh_p[3..100].to_s}"] = hh_p
   end
    

   #se ho ricevuto "num_booking", lo vado a decodificare in BookingItem
   if !params[:data][:num_booking].blank? && !params[:data][:num_booking].to_s.strip.empty?  
    bh = Booking.get_by_num(params[:data][:num_booking])
    bi = BookingItem.get_by_num_eq(params[:data][:num_booking], hh.equipment_id)
    if bh.nil? || bi.nil?
      if (bh.nil?)
        logger.info 'Booking non trovatot'
        render json: {:success => false, :message => "Booking inesistente"}
      else
        logger.info 'Booking non trovato per numero/equipment'
        render json: {:success => false, :message => "Il booking indicato non comprende l'equipment selezionato ( #{hh.equipment.equipment_type} )"}        
      end
      return
    else
     logger.info 'Booking trovato'
     params[:data][:booking_id] = bi.booking.id
     params[:data][:booking_item_id] = bi.id
     params[:data].delete(:num_booking)    
    end
   end

   #in ogni caso rimuovo "num_booking" (ad esempio in O_LOAD puo' essere passato blank...
   params[:data].delete(:num_booking)
     
   
   params[:data].permit!
   hi.assign_attributes(params[:data])

   unless params[:set_lock_type].nil?
     hi.set_lock(params[:set_lock_type])
   end  
     
   #se supera i vari controlli salvo il dettalio e aggiorno la testata
   validate_insert_item = hh.validate_insert_item(hi)
   if validate_insert_item[:is_valid]
    hi.save!()   
    hh.assign_attributes(hh_params) 
    r = hh.sincro_save_header(hi)
    ret_status  = r[:success]
    message     = r[:message]
   else
    ret_status = false
    message = validate_insert_item[:message]
   end 
       
   render json: {:success => ret_status, :message => message, :hh=>[hh.as_json(extjs_sc_model.constantize.as_json_prop)]} 
end



 #azzero il flag to_be_moved (eseguito dal mulettista dopo aver movimentato il container)
 ##################################################
 def hitems_close_to_be_moved
 ##################################################
   hi = HandlingItem.find(params[:data][:handling_item_id])
   hi.to_be_moved = false
   hi.moved_by_user_id = current_user.id
   hi.moved_at = Time.zone.now
   hi.save!
   render json: {:success => true, :message => nil}      
 end
 
 
 #modifico i dati di un dettaglio (ship/voyage...)
 def hitems_edit_simple
   @item = HandlingItem.find(params['rec_id'])
 end

 #modifica ora allaccio/disallaccio
 def hitems_edit_rfcon
   @item = HandlingItem.find(params['rec_id'])
 end

 
 def hitems_edit_simple_save
   item = HandlingItem.find(params[:data][:id])
     
   if !params[:data][:datetime_op_date].to_s.empty? && !params[:data][:datetime_op_time].to_s.empty?
     #datetime_op (data e ora) lo trasformo in datetime
     params[:data][:datetime_op] = generate_datetime(params[:data][:datetime_op_date], params[:data][:datetime_op_time]) 
     params[:data].delete(:datetime_op_date)
     params[:data].delete(:datetime_op_time)
   else
     params[:data][:datetime_op] = Time.zone.now
   end

   if !params[:data][:datetime_op_end_date].to_s.empty? && !params[:data][:datetime_op_end_time].to_s.empty?
     #datetime_op (data e ora) lo trasformo in datetime
     params[:data][:datetime_op_end] = generate_datetime(params[:data][:datetime_op_end_date], params[:data][:datetime_op_end_time]) 
     params[:data].delete(:datetime_op_end_date)
     params[:data].delete(:datetime_op_end_time)
   end
   
   
        
   params[:data][:fl_send_email_carrier] = nil if params[:data][:fl_send_email_carrier] == false
             
   params[:data].permit!
   #filtro solo gli attributi presenti nel model e salvo
   item.update(params[:data])
   item.save!()
   hh = item.handling_header 
   render json: {:success => true, :message => '', :hh=>[hh.as_json(HandlingHeader.as_json_prop)]}    
 end


 
 
 
 
# Inserimento dettaglio movimento
##################################################
def edit_header  
##################################################
 @item = HandlingHeader.find(params['rec_id'])
end 

##################################################
  def get_booking_combo_data
##################################################  
    render json: Booking.limit(500)
  end
  
 
#VISTE PERSONALIZZATE  
   
##################################################
 def list_by_filtered_type
##################################################  
   render :partial=>"filtered_#{params[:filtered_type]}", :locals => {:filtered_type => params[:filtered_type] }
 end

##################################################
 def get_row_by_filtered_type
##################################################     
   case params[:filtered_type]

    when 'lock_INSPECT'         
     #per ogni hh aggiungo altre informazioni 
     hh_as_json_prop = HandlingHeader.as_json_prop
     hh_as_json_prop[:methods] << :get_lock_INSPECT_date         
     render json: HandlingHeader.where('1=1').locked_INSPECT.limit(1000).as_json(hh_as_json_prop)
     
     when 'lock_DAMAGED'         
      #per ogni hh aggiungo altre informazioni 
      hh_as_json_prop = HandlingHeader.as_json_prop
      hh_as_json_prop[:methods] << :get_lock_DAMAGED_date         
      render json: HandlingHeader.where('1=1').locked_DAMAGED.limit(1000).as_json(hh_as_json_prop)

   when 'to_be_moved'          
     #per ogni hh aggiungo altre informazioni 
     hh_as_json_prop = HandlingItem.as_json_prop
     hh_as_json_prop[:include] = hh_as_json_prop[:include] || [] 
     hh_as_json_prop[:include] << {:handling_header => {:include=>[:equipment, :shipowner]}}              
     render json: HandlingItem.where('1=1').to_be_moved.limit(1000).as_json(hh_as_json_prop)     
   end 
 end
   

end
