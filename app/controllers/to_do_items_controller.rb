class ToDoItemsController < ApplicationController
 
  def extjs_sc_model
   'ToDoItem'
  end   
  
  
  
  def verify_empty_container_in_terminal
    #params[:data]
    
    if params[:data][:shipowner_id].to_i == 0 || params[:data][:equipment_id].to_i == 0
      render json: {success: false, message: 'Parametri non completi'}
      return
    end
    
    #conteggio
    items = HandlingHeader.is_in_terminal().not_closed()
    items = items.where(handling_headers: {shipowner_id: params[:data][:shipowner_id]})
    items = items.where(handling_headers: {equipment_id: params[:data][:equipment_id]})
    items = items.where(handling_headers: {container_FE: 'E'})
    
    min_entrato_il = Time.zone.now
    items.each do |hi|
      min_entrato_il = [hi.last_IN().datetime_op, min_entrato_il].min
    end  
      
    #giorni max vecchiaia
    g_days = (Time.zone.now - min_entrato_il).to_i / 1.day
      
    render json: {success: true, count: items.count, min_entrato_il: min_entrato_il, g_days: g_days}
    
  end
  
  
  
  
  
  
  #come lista mostro solo le liste aperte
  ##########################################
   def extjs_sc_list
  ########################################## 
    model_class = extjs_sc_model.to_s
    
    items = model_class.constantize.extjs_default_scope
    
     #gestione eventuali filtri
     unless params[:my_filters].nil?
       params[:my_filters].each do |kp, p|
         case kp
         when 'created_at_from'
           items = items.where("created_at >= ?", Time.zone.parse(p).beginning_of_day) unless p.blank?           
         when 'created_at_to'
           items = items.where("created_at <= ?", Time.zone.parse(p).beginning_of_day) unless p.blank?
         else
           items = items.where("#{kp} = ?", p) unless p.blank?  
         end
         
       end
     else
        #default apertura 
        items = items.not_closed  
     end  
      
    ret = {}
    ret[:items] = items.limit(params[:limit]).offset(params[:start]).as_json(model_class.constantize.as_json_prop)
    ret[:total] = model_class.constantize.extjs_default_scope.count
    
    render json: ret
   end  
 
  
  
  #Prenota uscita vuoto per riempimento
  def new_O_FILLING

    @item = ToDoItem.new
    @item.status = 'OPEN'
    @item.to_do_type = 'CONT_PRE_ASS'
    @item.handling_item_type = 'O_FILLING'
    @item.handling_type = 'O'
    @item.container_FE = 'E'
        
    
    #Inserimento record in ToDoItem
    if params[:exe_save] == 'Y'      
      @item.num_booking = params[:num_booking]
      @item.shipowner_id = params[:shipowner_id]
      @item.equipment_id = params[:equipment_id]
      @item.carrier_id   = params[:carrier_id]
      @item.driver       = params[:driver]
      @item.plate        = params[:plate]
      @item.notes        = params[:notes] if params[:notes] 

      hh = HandlingHeader.new
      hi = hh.handling_items.new()
      hh.shipowner = @item.shipowner
      hh.equipment = @item.equipment
        
              
      #verifico esistenza e validita booking  
       bh = Booking.get_by_num(params[:num_booking])
       bi = BookingItem.get_by_num_eq(params[:num_booking], @item.equipment_id)
       if bh.nil? || bi.nil?
         if (bh.nil?)
           render json: {:success => false, :message => "Booking inesistente"}
         else
           render json: {:success => false, :message => "Il booking indicato non comprende l'equipment selezionato ( #{hh.equipment.equipment_type} )"}        
         end
         return
       end
       
      hi.booking = bh
      hi.booking_item = bi   
      verifica_validazione = hi.booking.valida_insert_item(hi)    
          
        if verifica_validazione[:is_valid] == false
              render json: {:success => false, :message => verifica_validazione[:message]}   
              return   
        end        

      
      #se sono qui procedo al salvataggio
      r = @item.save  
      
      if r
        message = 'Salvataggio esequito'
      else
        message = 'Errore in fase di salvataggio'
      end
      
      render json: {:success => r, :message => message}
      return
    end
    
  end
  
  

  
  
  
  
  #Nuova nota per mulettisti
  def new_POST_IT_MUL

    @item = ToDoItem.new
    @item.status = 'OPEN'
    @item.to_do_type = 'POST_IT_MUL'
    
    #Inserimento record in ToDoItem
    if params[:exe_save] == 'Y'     
      @item.container_number = params[:container_number]
      @item.notes            = params[:notes]
           
            
      #se sono qui procedo al salvataggio
      r = @item.save  
      
      if r
        message = 'Salvataggio esequito'
      else
        message = 'Errore in fase di salvataggio'
      end
      
      render json: {:success => r, :message => message}
      return
    end
    
  end
  
      
  
  def list_POST_IT_MUL
  end
  
  #come lista mostro solo le liste aperte
  ##########################################
   def get_list_POST_IT_MUL
  ########################################## 
    model_class = extjs_sc_model.to_s
    
    items = model_class.constantize.post_it_mul
    
     #gestione eventuali filtri
     unless params[:f_values].nil?
       params[:f_values].each do |kp, p|
         case kp
         when 'flt_date_from'
           items = items.where("created_at >= ?", Time.zone.parse(p).beginning_of_day) unless p.blank?           
         when 'flt_date_to'
           items = items.where("created_at <= ?", Time.zone.parse(p).beginning_of_day) unless p.blank?
         when 'show_executed'
           items = items.where("status <> 'CLOSE'") if p == 0  
         when 'show_not_executed'
           items = items.where("status <> 'OPEN'") if p == 0           
         end
         
       end
     else
        #default apertura 
        items = items.where("status = 'OPEN' or created_at >= ?", 1.week.ago)  
     end  
      
    ret = {}
    ret[:items] = items.limit(params[:limit]).offset(params[:start]).as_json(model_class.constantize.as_json_prop)
    ret[:total] = model_class.constantize.extjs_default_scope.count
    
    render json: ret
   end 
  
  
  
  #viene assegnato dal mulettista un container a una prenotazione
  def close_to_be_moved
    to_do_item_id = params[:data][:to_do_item_id]
    num_container = params[:data][:num_container].to_s.upcase
            
    tdi = ToDoItem.find(to_do_item_id)
    
    
    if tdi.to_do_type == 'POST_IT_MUL'
      tdi.status = 'CLOSE'
      tdi.notes_int = params[:data][:notes_int]      
      tdi.save!() 
      render json: {:success => true}
      return
    end
       
      
    ### DEFAULT: to_do_type = CONT_PRE_ASS  
    hh = HandlingHeader.not_closed.container(num_container).first    

    #errore se non trovo il movimento aperto per il container
    if hh.nil?
       ret_status  = false
       message     = "Non trovato un movimento aperto per questo container"       
       render json: {:success => ret_status, :message => message}
       return
    end

    #costruisco la nuova riga di dettaglio (recuperando i parametri dal to_do_item)
    hi = hh.handling_items.new()
    
        
     #verifico equipment e compagnia
     if hh.equipment_id != tdi.equipment_id
       ret_status  = false
       message     = "Tipologia di container non corrispondente"       
       render json: {:success => ret_status, :message => message}
       return       
     end
     if hh.shipowner_id != tdi.shipowner_id
       ret_status  = false
       message     = "Compagnia non corrispondente"       
       render json: {:success => ret_status, :message => message}
      return       
     end
     

    hi.datetime_op = Time.now
    hi.moved_at    = hi.datetime_op
    hi.to_be_moved = false	#e' appena stato movimentato
    
    #se volessi impostae datetime_op con la data di creazione del ToDo, e moved_at = now
    #ma rischierei che datetime_op sia inferire all'ultimo hi
    #hi.datetime_op   = tdi.created_at
    #hi.moved_at      = Time.now
    
    
    hi.notes = params[:data][:notes] unless params[:data][:notes].blank?
    hi.handling_item_type = tdi.handling_item_type
    hi.handling_type = tdi.handling_type
    hi.container_FE = tdi.container_FE
    hi.carrier_id   = tdi.carrier_id
    hi.driver       = tdi.driver
    hi.plate        = tdi.plate
    
   #controllo su numero booking
   if !tdi.num_booking.blank?  
    bh = Booking.get_by_num(tdi.num_booking)
    bi = BookingItem.get_by_num_eq(tdi.num_booking, hh.equipment_id)
    if bh.nil? || bi.nil?
      if (bh.nil?)
        logger.info 'Booking non trovato'
        render json: {:success => false, :message => "Booking inesistente"}
      else
        logger.info 'Booking non trovato per numero/equipment'
        render json: {:success => false, :message => "Il booking indicato non comprende l'equipment selezionato ( #{hh.equipment.equipment_type} )"}        
      end
      return
    else
     logger.info 'Booking trovato'
     hi.booking_id = bi.booking.id
     hi.booking_item_id = bi.id    
    end
   end
    
   
   #verifico e inserisco
    #se supera i vari controlli salvo il dettalio e aggiorno la testata
    validate_insert_item = hh.validate_insert_item(hi)
    confirmed = false
    if validate_insert_item[:is_valid]
    
		 #se non avevo verificato il num_container ritorno il num_container verificato
		  if params[:data][:num_container].to_s.upcase != params[:data][:num_container_verified].to_s.upcase
		   
		   #ritorno anche le note per il container selezionato
		   notes_all = hh.get_notes_all()
		   
		   render json: {:success => true,
		   	 			  :num_container_verified => params[:data][:num_container].to_s.upcase,
		   				  :message => "Confermare scelta container",
		   				  :notes_all => notes_all,
		   				  :hh_id => hh.id}
		   return
		  end 	    
    
      hi.save!()       
      r = hh.sincro_save_header(hi) 
                                    
      #metto il tdi in CLOSE
      if (r[:success])
        tdi.status = 'CLOSE'
        tdi.generated_handling_item_id = hi.id
        tdi.save!()        
      end
      
      ret_status  = r[:success]
      message     = r[:message]
      confirmed   = true      
    else
        ret_status  = validate_insert_item[:is_valid]
        message     = validate_insert_item[:message]         
    end
    
    render json: {:success => ret_status, :message => message, :confirmed => confirmed}   
  end
  
end
