class ToDoItemsController < ApplicationController
 
  def extjs_sc_model
   'ToDoItem'
  end   
  
  
  #viene assegnato dal mulettista un container a una prenotazione
  def close_to_be_moved
    to_do_item_id = params[:data][:to_do_item_id]
    num_container = params[:data][:num_container]
      
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
    if validate_insert_item[:is_valid]
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
    else
        ret_status  = validate_insert_item[:is_valid]
        message     = validate_insert_item[:message]         
    end
    
    render json: {:success => ret_status, :message => message}   
  end
  
end
