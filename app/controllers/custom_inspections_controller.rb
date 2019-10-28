class CustomInspectionsController < ApplicationController
  layout "application_report", only: [:list_r]

  #inserimento nuova richiesta
  def new_request
    @item = Activity.new
    render :partial => "new_request"
  end
    
  
  ####################################################     
  def exe_save
  ####################################################    
    logger.info params.to_json
    to_h_data = params.dup  #clono perche' altrimenti non ritrovo i valori rimossi con delete    
    to_h_data.except!("container_number", "container_notes", "authenticity_token", "controller", "action").permit!
    
    item = Activity.new
    item.activity_type_id = ActivityType.find_by_code('CUST_INSPECTION').id
    item.update(to_h_data)
    
    #scrivo le righe di dettagli containers
    cc = 0
    params["container_number"].each do |c|
      if !c.strip.blank?
        c_notes = params["container_notes"][cc].blank? ? nil : params["container_notes"][cc]
        item.activity_dett_containers.new(container_number: c.strip, creation_notes: c_notes)
      end
      cc += 1
    end    
    
    item.save!()
    
    
    text_email = "
<h2>Notifica inserimento nuova attivit&agrave;</h2>
Utente: #{item.created_user_name}<br/>
Cliente: #{item.customer.name}<br/>
Compagnia: #{item.shipowner.name}<br/>
Operazione: #{item.activity_op.name}<br/>
Messa a disposizione: #{item.to_be_made_available ? "Si" : "No"}<br/>
Terminal: #{item.terminal.name}<br/>
Booking: #{item.booking_number.to_s}<br/>
Quantit&agrave;: #{item.quantity}<br/>
Da effettuare il: #{item.expiration_date}<br/>
Note: #{item.notes.to_s}<br/>
------------<br/>"

    params["container_number"].each do |c|
      text_email += "Container: #{c.strip}<br/>" if !c.strip.empty?
    end
    
    text_email += "<br/><br/>medaT software for Icop"


    LogEvent.send_mail_html(item, 'NEW_ACTIVITY', merge_email_to(item.customer.email_notify_activity.to_s, TabConfig.get_notes('EMAIL', 'CUST_INSP', 'NEW_ACT').to_s), 'Notifica nuova attività', text_email)
    
    #solo se e' stata richiesta la messa a disposizione invio email a Agenzia (Archibugi)
    if (item.to_be_made_available)
      LogEvent.send_mail_html(item, 'NEW_ACT_MA', merge_email_to('', TabConfig.get_notes('EMAIL', 'CUST_INSP', 'NEW_ACT_MA').to_s), 'Notifica nuova attività con Messa a disposizione', text_email)
    end
    
    
    render json: {:success => true}
  end
  
  
  
  ##### DETTAGLI ########################################################
  def activity_dett
    @item = Activity.find(params[:rec_id])      
  end
  
  def activity_dett_list
    @item = Activity.find(params[:activity_id])
    @item_detts = @item.activity_dett_containers
    
    if params[:set_amount] == true
      #preimposto (se presente) il prezzo di default dell'attivita', a meno che non abbia gia' un prezzo sul dettaglio
      @item_detts.collect! { |ad|
         ad.recalculate_gest_price = ad.recalculate_gest_price.nil? ? @item.activity_op.recalculate_gest_price : ad.recalculate_gest_price         
         ad.op_amount = @item.activity_op.recalculate_gest_price == true ? nil : @item.activity_op.default_price.to_i if ad.op_amount.nil?
      }
    end    
      
    render json: {:success => true, items: @item_detts}
  end
  
  def set_available
    item = ActivityDettContainer.find(params[:rec_id])
    item.make_available_at      = Time.zone.now    
    item.make_available_notes   = params[:check_form][:notes] unless params[:check_form].nil?       
    item.make_available_user_id = current_user.id
    item.save!
    
    
    text_email = "
<h2>Notifica messa a disposizione</h2>
Container: #{item.container_number}<br/>
Operazione: #{item.activity.activity_op.name}<br/>
Compagnia: #{item.activity.shipowner.name}<br/>
Utente: #{item.make_available_user_name}<br/>    
------------<br/><br/><br/>medaT software for Icop"

    LogEvent.send_mail_html(item, 'MAKE_AV', merge_email_to(item.activity.customer.email_notify_activity.to_s, TabConfig.get_notes('EMAIL', 'CUST_INSP', 'MAKE_AV').to_s), "Notifica messa a disposizione - Container: #{item.container_number}", text_email)
    
    render json: {:success => true}
  end
  
  def set_execution
    item = ActivityDettContainer.find(params[:rec_id])
    item.execution_at      = Time.zone.now
    item.execution_date    = Time.zone.now
    item.execution_notes   = params[:check_form][:notes]       
    item.execution_user_id = current_user.id    
    item.save!
    
    text_email = "
<h2>Notifica attività eseguita</h2>
Container: #{item.container_number}<br/>
Operazione: #{item.activity.activity_op.name}<br/>
Compagnia: #{item.activity.shipowner.name}<br/>
Utente: #{item.execution_user_name}<br/>    
------------<br/><br/><br/>medaT software for Icop"

    LogEvent.send_mail_html(item, 'EXEC', merge_email_to(item.activity.customer.email_notify_activity.to_s, TabConfig.get_notes('EMAIL', 'CUST_INSP', 'EXEC').to_s), "Notifica attività eseguita - Container: #{item.container_number}", text_email)    
    
    render json: {:success => true}
  end
  
  def add_container_to_activity_dett
    item = Activity.find(params[:activity_id])
    item.activity_dett_containers.new(container_number: params[:check_form][:container_number])
    item.save!  
    render json: {:success => true}
  end  
  
  
  ##################################################
   def modify_record
  ##################################################
    @item = ActivityDettContainer.find(params[:rec_id])    
    @from_component_id = params[:from_grid_id]
   end
   
  ##################################################
   def exe_modify_record
  ##################################################
    item = ActivityDettContainer.find(params[:data][:id])    
    params[:data].permit!
    item.update(params[:data])
    ret = item.save!  
    render json: {success: ret}
   end   
   
   
  ##################################################
   def list_to_confirm
  ##################################################    
   end
   

   ##################################################
   def list_all
   ##################################################    
   end
   
   

   ##################################################
   def list_to_confirm_data
   ##################################################
     items = ActivityDettContainer.eager_load(:activity).preload(:activity_op, :shipowner)
            .where("(activities.status IS NULL OR activities.status <> 'ANN') AND (activity_dett_containers.status IS NULL or activity_dett_containers.status <> 'ANN')")
            .where("confirmed_at IS NULL")
            #### al momento le mostro tutte
            #.where(" activity_dett_containers.execution_at IS NOT NULL 
            #        OR activities.to_be_made_available IS NULL OR activities.to_be_made_available = 0 
            #        OR (activities.to_be_made_available = 1 AND activity_dett_containers.make_available_at IS NOT NULL) 
            #        OR (activities.expiration_date > #{Date.today})")
     if !params[:f_values].blank?               
      items = items.where("container_number LIKE  ?", "%#{params[:f_values][:flt_num_container].strip}%") unless params[:f_values][:flt_num_container].empty? 
     end      
     items = items.order("activities.expiration_date").limit(300)
                        
     render json: {:success => true, items: items.as_json(ActivityDettContainer.as_json_prop)}
   end
     

   
   
    ##################################################
    def list_all_data
    ##################################################
      items = ActivityDettContainer.eager_load(:activity).preload(:activity_op, :shipowner)
      if !params[:f_values].blank?               
       items = items.where("container_number LIKE  ?", "%#{params[:f_values][:flt_num_container].strip}%") unless params[:f_values][:flt_num_container].empty?
        items = items.where("activities.expiration_date >= ?", Time.zone.parse(params[:f_values]['flt_date_from']).beginning_of_day) unless params[:f_values]['flt_date_from'].blank?
        items = items.where("activities.expiration_date <= ?", Time.zone.parse(params[:f_values]['flt_date_to']).end_of_day) unless params[:f_values]['flt_date_to'].blank?
        
        items = items.where("activity_dett_containers.execution_date IS NULL") if params[:f_values]['show_executed'] == 0  
        items = items.where("activity_dett_containers.execution_date IS NOT NULL")     if params[:f_values]['show_not_executed'] == 0
      end
      
      items = items.order("activities.expiration_date desc").limit(200)
                         
      render json: {:success => true, items: items.as_json(ActivityDettContainer.as_json_prop)}
    end

      
   def verify_container_exists
     item = search_hh_tmov_open(params[:data][:container_number], params[:data][:activity][:shipowner_id])
     render json: {:success => true, item: item}
   end
     

   
   
   #il cliente conferma l'effettiva esecuzione della visita (che poi puo' essere fatturata)
   #se il container e' gestito in medaT allora salvo anche il sigillo
   def exe_customer_confirmation
     item = ActivityDettContainer.joins(:activity).find(params[:rec_id])
     #se ho passato sigillo recupero hh e salvo il sigillo come fase di importo o export
     if !params[:check_form][:nuovo_sigillo].nil?
      hh = search_hh_tmov_open(item.container_number, item.activity.shipowner_id)
      if hh
        to_log = {}
        hi = hh.last_dett
        if hi.is_import_export == 'I'
          to_log['seal_imp_others'] = {from: hh.seal_imp_others, to: params[:check_form][:nuovo_sigillo]}   
          hh.seal_imp_others =  params[:check_form][:nuovo_sigillo]
        else
          to_log['seal_exp_others'] = {from: hh.seal_exp_others, to: params[:check_form][:nuovo_sigillo]}
          hh.seal_exp_others =  params[:check_form][:nuovo_sigillo]
        end
        hh.save!
        
        #loggo la modifica del sigillo
        LogEvent.base(hh, 'U', 'cu_inspect_confirmed', to_log)
      end
     end
     
     #salvo i dati
     item.confirmed_at      = Time.zone.now
     item.confirmed_user_id = current_user.id
     item.confirmed_notes   = params[:check_form][:notes]
     item.save!
     
      #loggo
      LogEvent.base(item, 'U', 'cu_inspect_confirmed')

      #Invio notifica email      
text_email = "
<h2>Notifica attività confermata</h2>
Container: #{item.container_number}<br/>
Operazione: #{item.activity.activity_op.name}<br/>
Compagnia: #{item.activity.shipowner.name}<br/>
Utente: #{item.confirmed_user_name}<br/>    
------------<br/><br/><br/>medaT software for Icop"

LogEvent.send_mail_html(item, 'CONF', merge_email_to(item.activity.customer.email_notify_activity.to_s, TabConfig.get_notes('EMAIL', 'CUST_INSP', 'CONF').to_s), "Notifica attività confermata - Container: #{item.container_number}", text_email)    
      
          
     render json: {:success => true}
   end
   
   
   
   def exe_postpones
     item = ActivityDettContainer.joins(:activity).find(params[:rec_id])
     ac = item.activity
     ac.expiration_date = params[:check_form][:new_date]
     ac.save!
     
     #loggo
     LogEvent.base(ac, 'U', 'postpones', {to: ac.expiration_date, notes: params[:check_form][:notes]})     
     render json: {:success => true}   
   end
   

  def exe_dett_ann
    item = ActivityDettContainer.joins(:activity).find(params[:rec_id])
    item.status = 'ANN'
    item.save!
    
    #loggo
    LogEvent.base(item, 'U', 'ann', {notes: params[:check_form][:notes]})     
    render json: {:success => true}   
  end
  
  
  def verify_not_pending_exists
    #verifico se ci sono delle richieste che sono "scadute" (vanno posticipate) o sono state eseguite e devono essere confermate
    num_pending = ActivityDettContainer.num_pending
    if num_pending == 0
      render json: {:success => true}
    else
      render json: {:success => false, message: "Ci sono #{num_pending} richieste in sospeso che devono essere confermate, posicipate o annullate. Utilizza il menu \"Conferma/gestisci visite doganali\" per gestirle"}
    end
  end

  
  def list_r
  end   
   
   private
   
   def search_hh_tmov_open(container_number, shipowner_id)
     HandlingHeader.find_by({container_number: container_number, shipowner_id: shipowner_id, handling_type: 'TMOV', handling_status: 'OPEN'})
   end
     
end #class
