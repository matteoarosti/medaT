class HandlingHeadersController < ApplicationController

 def extjs_sc_model
  'HandlingHeader'
 end 


##################################################
def sc_create  #OVERRIDE DEL METODO STANDARD
##################################################
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
   hh = HandlingHeader.find(params[:data][:handling_header_id])
   hi = hh.handling_items.new()
   
   #datetime_op (data e ora) lo trasformo in datetime
   params[:data][:datetime_op] = generate_datetime(params[:data][:datetime_op_date], params[:data][:datetime_op_time]) 
   params[:data].delete(:datetime_op_date)
   params[:data].delete(:datetime_op_time)
   
   #sposto i valori passati per impostare i dati in testata (tutti quelli che iniziano per hh_)
   hh_filtered_params = params[:data].select{|k,v| k[0..2].to_s == 'hh_'}
   hh_params = {}
   for k_hh_p, hh_p in hh_filtered_params
    params[:data].delete(k_hh_p)
    hh_params["#{k_hh_p[3..100].to_s}"] = hh_p
   end

    

   #se ho ricevuto "num_booking", lo vado a decodifica in "booking_id"
   if !params[:data][:num_booking].blank?
    b = Booking.get_by_num(params[:data][:num_booking])
    if b.nil?
     logger.info 'Booking non trovato'
     render json: {:success => false, :message => 'Booking non trovato'}
     return
    else
     logger.info 'Booking trovato'
     params[:data][:booking_id] = b.id
     params[:data].delete(:num_booking)    
    end
   end

   params[:data].permit!
   hi.assign_attributes(params[:data])

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



  def get_booking_combo_data
    render json: Booking.limit(500)
  end

end
