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





##################################################
def hitem_convert_to_damaged
##################################################      
    hi = HandlingItem.find(params[:rec_id])    
    
    #se non c'e' gia' un repair aperto per per il movimento
    if (hi.handling_header.get_open_repair_handling_item.nil?)
      logger.info "Creo preventivo"
      rhi = RepairHandlingItem.create_from_hi(hi)
      rhi.disabled_wf_on_close = true
      rhi.save!
      
      hi.lock_type = 'DAMAGED'
      hi.notes_int = 'Impostato a danneggiato successivamente ' + hi.notes_int.to_s
      hi.save!      
    else
      logger.info "Esiste gia' un preventivo aperto"      
    end
      
    render json: {:success => true}
end




# Mostro esito cancellazione riga di dettaglio
##################################################
def hitem_delete_preview  
##################################################
  @item = HandlingItem.find(params[:rec_id])
  @ret = @item.handling_header.hitem_delete_preview(@item)   
end

#elimino dettaglio
def hitem_delete
  hi = HandlingItem.find(params[:rec_id])
  toChange = hi.handling_header.hitem_delete_preview(hi)
  if toChange[:success] == true
    toChange[:data].each do |f|
      hi.handling_header.send("#{f[:field]}=", f[:new_value])
      if f[:field] == 'num_booking'
        hi.handling_header.booking_id = nil
        hi.handling_header.booking_item_id = nil
      end 
    end
    hi.destroy!
    hi.handling_header.save!
    
  end
  render json: {:success => true, :hh=>[hi.handling_header.as_json(extjs_sc_model.constantize.as_json_prop)]}
end





# Visualizzazione grid dettagli
##################################################
def hitems_sc_list  
##################################################
  ret = {}
   ret[:items] = HandlingItem.handlingHeader(params[:handling_id]).joins(:handling_header).order('datetime_op, id').limit(1000).as_json(HandlingItem.as_json_prop)
   ret[:success] = true
   render json: ret 
end


# Inserimento dettaglio movimento
##################################################
def hitems_sc_create  
##################################################

  copy_params_data = params[:data].dup  #clono perche' altrimenti non ritrovo i valori rimossi con delete
  
  #per evitare anomalia carrier_id = 0 oppure ship_id = 0
  if (
      (!params[:data][:carrier_id].to_s.strip.empty? && params[:data][:carrier_id].to_i == 0) ||
      (!params[:data][:ship_id].to_s.strip.empty? && params[:data][:ship_id].to_i == 0)
      )
    render json: {:success => false, :message => "Attenzione: verificare correttamente i dati inseriti nei campi select"}
    return
  end
  
  #form personalizzata per set damages (da ispezione)
  if !params[:data][:formDamageValues].nil?
    formDamageValues = params[:data][:formDamageValues].with_indifferent_access
    params[:data].delete(:formDamageValues)
    
    ar_op_int = []
    ar_op_int = formDamageValues["op_int"] unless formDamageValues["op_int"].nil?  
    ar_op_off = []
    ar_op_off = formDamageValues["op_off"] unless formDamageValues["op_off"].nil?      
  else
    formDamageValues = {}
    ar_op_int = []
    ar_op_off = []      
  end
      
   if !params[:data][:set_lock_type_DAMAGED].nil?     
     params[:set_lock_type] = 'DAMAGED' if params[:data][:set_lock_type_DAMAGED] == true
     params[:data].delete(:set_lock_type_DAMAGED)
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
  
   #se passato memorizzo (e rimuovo) pti_type_id (serve per l'apertura del preventivo)
   params_pti_type_requested_id = params[:data][:pti_type_requested_id]
   params[:data].delete(:pti_type_requested_id)
     
   params[:data].permit!
   hi.assign_attributes(params[:data])

   unless params[:set_lock_type].nil?
     hi.set_lock(params[:set_lock_type])
   end  
     
   
  ActiveRecord::Base.transaction do   
   begin     
     #se supera i vari controlli salvo il dettalio e aggiorno la testata
     validate_insert_item = hh.validate_insert_item(hi)
     if validate_insert_item[:is_valid]
      hi.save!()   
      hh.assign_attributes(hh_params) 
      r = hh.sincro_save_header(hi, copy_params_data)
      ret_status  = r[:success]
      message     = r[:message]
     else
      ret_status = false
      message = validate_insert_item[:message]
     end
     
     #se provengo da "Da movimentare" oltre a creare il movimento (inspect) chiudo la movimentazione
     if ret_status == true && !params[:handling_item_to_be_moved_close].to_s.empty?
       hi_moved = HandlingItem.find(params[:handling_item_to_be_moved_close])
       hi_moved.to_be_moved = false
       hi_moved.moved_by_user_id = current_user.id
       hi_moved.moved_at = Time.zone.now
       hi_moved.save!     
     end 
     
      #apro eventuale item in RepairHandlingItem
      if hi.lock_type == 'DAMAGED'
        rhi = RepairHandlingItem.create_from_hi(hi, {ar_op_int: ar_op_int, ar_op_off: ar_op_off, formDamageValues: formDamageValues}.with_indifferent_access)
      end
       
     render json: {:success => ret_status, :message => message, :hh=>[hh.as_json(extjs_sc_model.constantize.as_json_prop)]}
       
   rescue => exception
     to_rollback = true  
     logger.info exception.backtrace
     render json: {:success => false, :message => 'Errore sconosciuto. Contattare amministratore di sistema', :hh=>[hh.as_json(extjs_sc_model.constantize.as_json_prop)]}     
   end
   raise ActiveRecord::Rollback if to_rollback    
  end #transaction      
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


#modifica note
def hitems_edit_notes
  @item = HandlingItem.find(params['rec_id'])
end
 
#su dettaglio: modifica valori base (data/vettore/autista/....)
################################################
def hitems_edit_notes_save
################################################
  item = HandlingItem.find(params[:data][:id])
  params[:data].permit!
  #filtro solo gli attributi presenti nel model e salvo
  item.update(params[:data])
  item.save!()
  hh = item.handling_header 
  render json: {:success => true, :message => '', :hh=>[hh.as_json(HandlingHeader.as_json_prop)]}    
    
end



  
 #su dettaglio: modifica valori base (data/vettore/autista/....)
 ################################################
 def hitems_edit_simple_save
 ################################################
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
   
   
   #verifico che la data sia valida (compresa tra il movimento precedente e successivo)
   prev_datetime_op = nil
   next_datetime_op = nil
   finded = false
   
   item.handling_header.handling_items.order('datetime_op, id').each do |hi|
     if hi.id == item.id
       finded = true
       next #passo al record successivo 
     end
     
     if finded == false
       prev_datetime_op = hi.datetime_op
     end
     
     if finded == true
       next_datetime_op = hi.datetime_op
       break
     end 
   end
  
   
    
   if (!prev_datetime_op.nil? && params[:data][:datetime_op] < prev_datetime_op) || 
      (!next_datetime_op.nil? && params[:data][:datetime_op] > next_datetime_op)       
      render json: {:success => false, :message => "Data operazione non valida (verifica dettaglio movimento precedente o successivo)"}
      return
   end
   if  !params[:data][:datetime_op_end].nil?
     if (!prev_datetime_op.nil? && params[:data][:datetime_op_end] < prev_datetime_op) || 
        (!next_datetime_op.nil? && params[:data][:datetime_op_end] > next_datetime_op)       
        render json: {:success => false, :message => "Data operazione finale non valida (verifica dettaglio movimento precedente o successivo)"}
        return
     end
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
     items = HandlingHeader.where('1=1').not_closed.locked_INSPECT
     
     #prendo solo quelli che hanno un inspect aperto abbinato ad una nave
     items = items.joins(" INNER JOIN handling_items hi ON handling_headers.id = hi.handling_header_id AND hi.lock_fl = true
       AND handling_headers.lock_type = hi.lock_type AND hi.ship_id IS NOT NULL ")
     
     if !params[:flt_num_container].to_s.empty?
       items = items.where("container_number LIKE ?", "%#{params[:flt_num_container].upcase}%")
     end
       
       
     render json: items.limit(2000).as_json(hh_as_json_prop)
     
     when 'lock_DAMAGED_OLDDDD'
      #per ogni hh aggiungo altre informazioni 
      hh_as_json_prop = HandlingHeader.as_json_prop
      hh_as_json_prop[:methods] << :get_lock_DAMAGED_date     
      hh_as_json_prop[:methods] << :get_lock_DAMAGED_AU_date        
      items = HandlingHeader.where('1=1')
      case params[:form_user][:damaged_status]
        when 'TO_AUTH'
          items = items.where('lock_type=?', 'DAMAGED') 
        when 'AUTH'
          items = items.where('lock_type=?', 'DAMAGED_AU')
        else
          items = items.locked_DAMAGED          
      end    
      render json: items.limit(2000).as_json(hh_as_json_prop)
      
   when 'lock_DAMAGED'
     items = RepairHandlingItem.where('repair_status=?', 'OPEN')
     items = items.joins(:handling_header)
     render json: items.limit(2000).as_json(RepairHandlingItem.as_json_prop)     
        
  
   when 'to_be_cust_inspect'
     ret = []
     to_do_make_available = ActivityDettContainer.joins(:activity)
        .where("(activities.status IS NULL OR activities.status <> 'ANN') AND activities.execution_date  IS NULL AND (activity_dett_containers.status IS NULL or activity_dett_containers.status <> 'ANN')")
        .where(execution_at: nil)
        .order("activities.expiration_date")
     to_do_make_available.each do |ac|
       ret << {
         :to_be_moved_type => 'CUST_INSPECTION',
         :id => "CUST_INSPECTION_#{ac.id}", #attenzione: se ho lo stesso id di un handling_item potrebbe non essere visualizzato
         :rec_id => ac.id,
         :handling_type => 'CUST_INSPECTION',
         :container_FE => nil,
         :carrier_id_Name => nil,
         :driver => nil,
         :plate  => nil,
         :created_at => ac.created_at,
         :booking_notes => 'bbbbb',
         :handling_header => {
            :container_number => ac.container_number,
            :fila => '', :blocco => '', :tiro => '',
            :shipowner => {:name => ac.activity.shipowner.name},
            :customer  => {:name => ac.activity.customer.name},
            :equipment => {:equipment_type => '???'},
            :booking_number => ac.activity.booking_number,
            :quantity => ac.activity.quantity,
            :expiration_date => ac.activity.expiration_date
         }
       }         
     end
     render json: ret.as_json(HandlingItem.as_json_prop)     
        
     

   when 'to_be_moved'
     #per ogni hh aggiungo altre informazioni 11111
     hh_as_json_prop = HandlingItem.as_json_prop
     hh_as_json_prop[:include] = hh_as_json_prop[:include] || [] 
     hh_as_json_prop[:include] << {:handling_header => {:include=>[:equipment, :shipowner, :pier]}}
     ret = HandlingItem.joins(:handling_header).where('1=1').to_be_moved
     if !params[:flt_num_container].to_s.empty?
       ret = ret.where("handling_headers.container_number LIKE ?", "%#{params[:flt_num_container].upcase}%")
     end
     ret = ret.limit(500)
     
     
     #recupero tutte le prenotazioni container (uscita per riempimento, in cui e' il mulettista a scegliere il container)
     unless !params[:flt_num_container].to_s.empty?
       to_do_items = ToDoItem.where('1=1').not_closed.prenotazione_container.limit(1000).each do |tdi|
         b = Booking.get_by_num(tdi.num_booking)
         ret << {
           :to_be_moved_type => tdi.to_do_type,
           :id => tdi.id, #attenzione: se ho lo stesso id di un handling_item potrebbe non essere visualizzato
           :handling_type => tdi.handling_type,
           :container_FE => tdi.container_FE,
           :carrier_id_Name => tdi.carrier.nil? ? 'corriere non esistente' : tdi.carrier.name,
           :driver => tdi.driver,
           :plate  => tdi.plate,
           :created_at => tdi.created_at,
           :booking_notes => b.nil? ? 'booking non trovato' : b.notes,
           :handling_header => {
              :container_number => "DA ASSEGNARE",
              :fila => '', :blocco => '', :tiro => '',
              :shipowner => {:name => tdi.shipowner.name},
              :equipment => {:equipment_type => tdi.equipment.equipment_type}
           }
         }       
       end
     end
     
     #recupero elenco container da mettere a disposizione
     if params[:no_cust_inspect].nil? || params[:no_cust_inspect].to_s != "Y"
       to_do_make_available = ActivityDettContainer.joins(:activity)
          .where("(activities.status IS NULL OR activities.status <> 'ANN') AND activities.execution_date  IS NULL AND (activity_dett_containers.status IS NULL or activity_dett_containers.status <> 'ANN')")
          .where(activities: {to_be_made_available: true})
          .where(make_available_at: nil)
          .order("activities.expiration_date")
       to_do_make_available.each do |ac|
         
         #recupero (se preente) il movimento relativo al container
         md_hh = HandlingHeader.container(ac.container_number).where(handling_status: 'OPEN').first
         
         if !md_hh.nil?
           nota_container = [
                            md_hh.equipment.equipment_type, 
                            md_hh.with_booking == true ? 'E' : 'I',
                            ac.activity.activity_op.short_name || ac.activity.activity_op.name
                            ].join(' | ')
         else
           nota_container = ac.activity.activity_op.name
         end
         
         ret << {
           :to_be_moved_type => 'CUST_INSPECTION',
           :id => "CUST_INSPECTION_#{ac.id}", #attenzione: se ho lo stesso id di un handling_item potrebbe non essere visualizzato
           :nota_container => nota_container,
           :rec_id => ac.id,
           :handling_type => 'CUST_INSPECTION',
           :container_FE => nil,
           :carrier_id_Name => nil,
           :driver => nil,
           :plate  => nil,
           :created_at => ac.created_at,
           :booking_notes => 'bbbbb',
           :handling_header => {
              :container_number => ac.container_number,
              :fila => '', :blocco => '', :tiro => '',
              :shipowner => {:name => ac.activity.shipowner.name},
              :customer  => {:name => ac.activity.customer.name},
              :equipment => {:equipment_type => '???'},
              :booking_number => ac.activity.booking_number,
              :quantity => ac.activity.quantity,
              :expiration_date => ac.activity.expiration_date
           }
         }         
       end
     end
     
     
     #ordino per data     
     render json: ret.sort_by{|a|
       if a.is_a? Hash
         a[:created_at]         
       else
         a.created_at
       end 
     }.as_json(hh_as_json_prop)     
   end 
 end
   
 
 
 #########################################################
 # attach interchange file to hi
 #########################################################
 def hi_attach_interchange
   @item = HandlingItem.find(params[:rec_id])
 end
 
 def hi_attach_interchange_exe
  item = HandlingItem.find(params[:id])
  item.scan_file = params[:file]
  ret = item.save!
  render json: {success: ret, hi_id: item.id}  
 end
 
 def hi_attach_interchange_view_scan_file
   @item = HandlingItem.find(params[:rec_id])
 end
 
 def hi_download_file
  @item = HandlingItem.find(params[:id])
   send_file @item.scan_file.path('original'),
               :type => @item.scan_file_content_type  
    
 end   
 
 def hi_delete_interchange_exe
  item = HandlingItem.find(params[:id])
  item.scan_file = nil
  ret = item.save!
  render json: {success: ret, hi_id: item.id}  
 end

  

end
