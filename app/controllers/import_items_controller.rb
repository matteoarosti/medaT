class ImportItemsController < ApplicationController

  def extjs_sc_model
    'ImportItems'
  end


  def import
    ImportItem.import(params[:file])
    redirect_to root_url, notice: "Items imported."
  end

  
  #per correggere il bug che ogni tanto in fase di sbarco non vengono generati correttamente tutti i movimenti
  # in import_items ho aggiunto l'id del hh che dovrebbe aver creato. Riaprio ii se non trovo l'hh
  def reopen_D_non_created
    ih = ImportHeader.find(params[:import_header_id])
    ih.import_items.where(status: 'OK').where('created_handling_header_id IS NOT NULL').each do |ii|
      if !HandlingHeader.exists?(ii.created_handling_header_id)
        ii.status = null
        ii.save!
      end
    end
    render json: {:success => true}
  end
  
  
  #################################################  
  def test_all
  #################################################
    ih = ImportHeader.find(params[:import_header_id])
      
    #recupero tutti gli import_item ancora da importare
    iis = ih.import_items.where('status IS NULL').order(:container_number)

    #Determina la tipologia del movimento da import_headers
    import_type = ih.import_type
    
    message_error = []    
         
    #per oguno eseguo l'import
    iis.each do |ii|
      if import_type == 'L'
        ret = import_L(ii, params, nil, true)
      else
        ret = import_D(ii, params, nil, true)
      end      
      
      if ret[:success] == false
        message_error << "#{ii.container_number}: #{ret[:message]}"
      end
      
    end

    global_success = false
    render json: {:success => global_success, :message => message_error.join('<br/>')}
  end 

  
  
    
  
  #################################################  
  def set_ok_all
  #################################################
    ih = ImportHeader.find(params[:import_header_id])
      
    #recupero tutti gli import_item ancora da importare
    iis = ih.import_items.where('status IS NULL').order(:container_number)

    #Determina la tipologia del movimento da import_headers
    import_type = ih.import_type
    
    message_error = []    
         
    #per oguno eseguo l'import
    iis.each do |ii|
      if import_type == 'L'
        ret = import_L(ii, params)
      else
        ret = import_D(ii, params)
      end      
      
      if ret[:success] == false
        message_error << "#{ii.container_number}: #{ret[:message]}"
      end
      
      ii.status = ret[:success]==true ? 'OK' : nil
      ii.notes = params[:check_form][:notes] unless params[:check_form][:notes].blank?
      ii.created_handling_header_id = ret[:created_handling_header_id]
      ii.save!      
      
    end

    global_success = message_error.empty? ? true : false
    render json: {:success => global_success, :message => message_error.join('<br/>')}
  end 
   
  
 #################################################  
  def set_ok
 #################################################
   rec = ImportItem.find(params[:rec_id])

   #Determina la tipologia del movimento da import_headers
   import_type = rec.import_header.import_type
   if import_type == 'L'
     ret = import_L(rec, params)
   else
     ret = import_D(rec, params)
   end

   rec.status = ret[:success]==true ? 'OK' : nil
   rec.notes = params[:check_form][:notes] unless params[:check_form][:notes].blank?
   rec.created_handling_header_id = ret[:created_handling_header_id]
   rec.save!
   ret[:data] = rec.as_json()
   render json: ret
  end

 #################################################  
  def set_damaged
 #################################################    
    rec = ImportItem.find(params[:rec_id])
 
    #Determina la tipologia del movimento da import_headers
    import_type = rec.import_header.import_type
    if import_type == 'L'
      ret = import_L(rec, params, 'DAMAGED')
    else
      ret = import_D(rec, params, 'DAMAGED')
    end
 
    rec.status = ret[:success]==true ? 'DAMAGED' : nil
    rec.notes = params[:check_form][:notes] unless params[:check_form][:notes].blank?
    rec.created_handling_header_id = ret[:created_handling_header_id]
    rec.save!
    ret[:data] = rec.as_json()
    render json: ret
  end

 #SBARCO #########################################
  def import_D(rec, params, lock_type = nil, only_test = false)
 #################################################    
    hh = HandlingHeader.create_new(rec, params, only_test)
    if hh == false
      ret_status  = false
      message     = "Esiste gia' un movimento aperto per questo container"
      return {:success => ret_status, :message => message}
    end
    
    if !only_test && hh.id.nil?
      #anomalia: non e' riuscita la scrittura del movimento su db???
      ret_status  = false
      message     = "Anomalia: errore in fase di scrittura movimento su db"
      return {:success => ret_status, :message => message}      
    end
    
    if only_test
      #se sono in fase di test non vado oltre
      ret_status  = true
      message     = nil
      return {:success => ret_status, :message => message}      
    end
    
    
    
    #copio in handling_header weight/imo/temperature (da record di import_item)
    hh.temperature_imp  = rec.temperature  if !rec.temperature.nil? && rec.temperature.to_f != 0
    hh.weight_imp       = rec.weight       if !rec.weight.nil? && rec.weight.to_f != 0
    hh.imo_imp          = rec.imo          if !rec.imo.blank?    
    
    hi = hh.handling_items.new()
    hi.pier_id = params[:check_form][:pier_id]
    hi.gru_id  = params[:check_form][:gru_id]    
    hi.datetime_op = Time.now
    unless params[:check_form][:datetime_op_date].blank? || params[:check_form][:datetime_op_time].blank?
      hi.datetime_op = generate_datetime(params[:check_form][:datetime_op_date], params[:check_form][:datetime_op_time])      
    end
    hi.notes = params[:check_form][:notes] unless params[:check_form][:notes].blank?
    
    case rec.import_header.handling_type
      when 'FRCON'
        hi.handling_item_type = "START_RFCON"
      else #TMOV
        hi.handling_item_type = "I_DISCHARGE"
        hi.handling_type = "I"
        hi.container_FE = rec.container_status            
    end    
    
    hi.ship_id = rec.import_header.ship_id
    hi.voyage = rec.import_header.voyage
    
    #se supera i vari controlli salvo il dettalio e aggiorno la testata
    validate_insert_item = hh.validate_insert_item(hi)
    return validate_insert_item if only_test == true
    if validate_insert_item[:is_valid]
      hi.set_lock(lock_type) unless lock_type.nil? #eventuale flag DAMAGE
      hi.save!()
      r = hh.sincro_save_header(hi)
            
      ret_status  = r[:success]
      message     = r[:message]
    else
      ret_status  = validate_insert_item[:is_valid]
      message     = validate_insert_item[:message]
    end
   return {:success => ret_status, :message => message, :created_handling_header_id => hh.id}
  end

 #IMBARCO ###############################
  def import_L(rec, params, lock_type = nil, only_test = false)
 #################################################   
     hh = HandlingHeader.find_exist(rec, params)
     
     #se e' una uscita con container non gestiti, creo al volo l'handling_header
     if hh==false && rec.import_header.handling_type == 'OLOAD'
       hh = HandlingHeader.create_new(rec, params)
     end
     
     #errore se non trovo il movimento aperto per il container
     if hh == false
        ret_status  = false
        message     = "Non trovato un movimento aperto per questo container"
        return {:success => ret_status, :message => message}
     end 
     
     unless ['FRCON', 'OLOAD'].include?(rec.import_header.handling_type)
       #errore se FE non coincide tra la lista di imbarco e il movimento aperto
       if rec.container_status != hh.container_FE
         ret_status  = false
         message     = "Il valore Full/Empty indicato nella lista non coincide con lo stato attuale del movimento"
         return {:success => ret_status, :message => message}       
       end
     end
     
     
     hi = hh.handling_items.new()
     hi.pier_id = params[:check_form][:pier_id]
     hi.gru_id  = params[:check_form][:gru_id]
     hi.datetime_op = Time.now
     unless params[:check_form][:datetime_op_date].blank? || params[:check_form][:datetime_op_time].blank?
      hi.datetime_op = generate_datetime(params[:check_form][:datetime_op_date], params[:check_form][:datetime_op_time])      
     end
     hi.notes = params[:check_form][:notes] unless params[:check_form][:notes].blank?
       
     case rec.import_header.handling_type
      when 'FRCON'
        hi.handling_item_type = "END_RFCON"
      else #TMOV
        hi.handling_item_type = "O_LOAD"
        hi.handling_type = "O"
        hi.container_FE = rec.container_status            
     end    
              
     hi.ship_id = rec.import_header.ship_id
     hi.voyage = rec.import_header.voyage     
     
     #se e' impostato num_booking, provo a decodificarlo
    #se ho ricevuto "num_booking", lo vado a decodificare in BookingItem
    if !rec.num_booking.blank? && !rec.to_s.strip.empty?  
     bh = Booking.get_by_num(rec.num_booking)
     bi = BookingItem.get_by_num_eq(rec.num_booking, hh.equipment_id)
     if bh.nil? || bi.nil?
       if (bh.nil?)
         logger.info 'Booking non trovatot'
         return {:success => false, :message => "Booking inesistente"}
       else
         logger.info 'Booking non trovato per numero/equipment'
         return {:success => false, :message => "Il booking indicato non comprende l'equipment selezionato ( #{hh.equipment.equipment_type} )"}        
       end
       return
     else
      logger.info 'Booking trovato'
      hi.booking_id = bi.booking.id
      hi.booking_item_id = bi.id    
     end
    end

     
     
          
     #se supera i vari controlli salvo il dettalio e aggiorno la testata
     validate_insert_item = hh.validate_insert_item(hi)
     return validate_insert_item if only_test == true
     if validate_insert_item[:is_valid]
       hi.set_lock(lock_type) unless lock_type.nil? #eventuale flag DAMAGE
       hi.save!()       
       r = hh.sincro_save_header(hi) 
                                     
       ret_status  = r[:success]
       message     = r[:message]
     else
         ret_status  = validate_insert_item[:is_valid]
         message     = validate_insert_item[:message]         
     end
    return {:success => ret_status, :message => message}
   end

end
