class ToDoItemsController < ApplicationController
 
  def extjs_sc_model
   'ToDoItem'
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
  
  
  
  #viene assegnato dal mulettista un container a una prenotazione
  def close_to_be_moved
    to_do_item_id = params[:data][:to_do_item_id]
    num_container = params[:data][:num_container].to_s.upcase
      
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
    tdi = ToDoItem.find(to_do_item_id) 
        
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
        logger.info 'Booking non trovatot'
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
