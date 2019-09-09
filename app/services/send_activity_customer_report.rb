class SendActivityCustomerReport
  
  def call
    create_docs
    prepare_docs_file_and_send_email
  end
  
  
  
  #preparo, per ogni cliente, pdf da inviare con resconto attivita' del giorno  
  def create_docs
    
    #per ogni cliente
    activity_exec_or_confirmed_in_date.group_by { |r| r.activity.customer}.each do |customer, adcs|
      puts "Customer id: #{customer.id} - #{customer.name} (nr. attività: #{adcs.size})"
      
      #recupero (per cliente) eventuali activities con activity_type code != CUSTOM_INSPECTION
      acts = Activity.joins("LEFT OUTER JOIN activity_types ON activity_types.id = activities.activity_type_id")
                    .where(customer: customer)
                    .where("(activities.status IS NULL OR activities.status <> 'ANN')")
                    .where("activity_type_id is null OR activity_types.code != 'CUST_INSPECTION'")
                    .where("doc_h_notifica_id IS NULL")
                    .where("execution_at IS NOT NULL")
      
      #preparo il documento
      doc_type = DocType.find_or_create_by!(code: 'ADN') do |dt|
        dt.name = 'Resoconto attività'
      end
      
      DocH.transaction do
        dh = DocH.new(customer: customer, doc_type: doc_type, draft: true)
        dh.d_reg = Time.zone.today
        dh.assign_num
        dh.save!
        
        adcs.each do |i|
          i.doc_h_notifica_id = dh.id
          i.save!
        end
        
        acts.each do |i|
          i.doc_h_notifica_id = dh.id
          i.save!
        end
 
      end #transaction
    end
    
    
    #ciclo su activities (no cust_inspection)
    activity_exec_or_confirmed_in_date_from_actvities.group_by { |r| r.customer}.each do |customer, adcs|
        puts "Customer id: #{customer.id} - #{customer.name} (nr. attività: #{adcs.size})"
        
        #recupero (per cliente) eventuali activities con activity_type code != CUSTOM_INSPECTION
        acts = Activity.joins("LEFT OUTER JOIN activity_types ON activity_types.id = activities.activity_type_id")
                      .where(customer: customer)
                      .where("(activities.status IS NULL OR activities.status <> 'ANN')")
                      .where("activity_type_id is null OR activity_types.code != 'CUST_INSPECTION'")
                      .where("doc_h_notifica_id IS NULL")
                      .where("execution_at IS NOT NULL")
        
        #preparo il documento
        doc_type = DocType.find_or_create_by!(code: 'ADN') do |dt|
          dt.name = 'Resoconto attività'
        end
        
        DocH.transaction do
          dh = DocH.new(customer: customer, doc_type: doc_type, draft: true)
          dh.d_reg = Time.zone.today
          dh.assign_num
          dh.save!
                    
          acts.each do |i|
            i.doc_h_notifica_id = dh.id
            i.save!
          end
    
        end #transaction
      end

    
  end
  
  
  
  
  def prepare_docs_file_and_send_email
    items = DocH.where(doc_type: DocType.find_by!(code: 'ADN')).where(doc_file_file_name: nil).each do |d|
      puts "Genero pdf per #{d.id} doc"
      
      tmp_file_name = Tempfile.new(['activity_customer_report_', '.pdf']).path
      #tmp_file_name = 'tmp/aaaaa.pdf'
      print "\nGenero #{tmp_file_name}"    
      pdf = ActivityCustomerReportPdf.new()
      pdf.draw(d)
      pdf.render_file(tmp_file_name)      
      print "\nGenerato"
      d.doc_file = File.open(tmp_file_name)
      d.save!      
      send_doc_email(d)      
    end      
  end
  
  
  
  def test_csv_eSolver(anno, numero)
    d = DocH.where(doc_type: DocType.find_by!(code: 'ADN')).where(nr_anno: anno, nr_seq: numero).first
    #csv per eSolder (Fatturazione elettronica)
    tmp_file_name_csv_fe = Tempfile.new(['activity_customer_fe_', '.csv']).path
    print "\nGenero #{tmp_file_name_csv_fe} (Fatturazione Elettronica)"    
    tmp_file_csv_fe = File.open(tmp_file_name_csv_fe, "W")
    tmp_file_csv_fe.puts prepare_csv_FE_eSolver(d)
    tmp_file_csv_fe.close
    print "\nGenerato"
  end
  
  
  def prepare_csv_FE_eSolver(d)
    ar_out = []
    #intestazione
    ar_out << "TES:Tipo record;TES:Data servizio;TES:Numero progressivo;TES:Codice cliente;TES:Tipo lavoro;TES:Commento;RIG:Codice servizio;RIG:quantità;RIG:Centro analisi;RIG:Descrizione riga;RIG:Descrizione estesa;Numero ore;Banchina;Orario iniziale;Orario finale;% maggiorazione"
    #record di testata
    ar_out << ['TES',
            d.created_at.strftime("%Y%m%d"),
            d.nr_seq,
            d.customer.gest_code
        ].join(';')
        
    #righe (dett)
    ActivityDettContainer.where(doc_h_notifica_id: d.id).each do |rec|
      out_data = min(rec.confirmed_at, rec.execution_at)
      importo = rec.activity_op.recalculate_gest_price.nil? ? 0 : rec.amount
      ar_out << ['RIG',
                  out_data.strftime("%Y%m%d"),
                  d.nr_seq,
                  d.customer.gest_code,
                  'tipo lavoro???',
                  '', #commento
                  rec.activity_op.gest_code, #codice servizio,
                  1, #quantita????
                  '', '', '',   #centro analisi, descrizione riga, descrizione estesa
                  importo
              ].join(';')        
    end
            
    
    #righe (no dett)              
    Activity.where(doc_h_notifica_id: docH.id).each do |rec|
      out_data = rec.execution_at
      importo = rec.amount
      ar_out << ['RIG',
                  out_data.strftime("%Y%m%d"),
                  d.nr_seq,
                  d.customer.gest_code,
                  'tipo lavoro???',
                  '', #commento
                  rec.activity_op.gest_code, #codice servizio,
                  1, #quantita????
                  '', '', '',   #centro analisi, descrizione riga, descrizione estesa
                  importo
              ].join(';')
    end

     
    return c_out.join("\n")
  end
  
  
  
  def send_doc_email(docH)
      begin
       if !docH.customer.nil?
           text_email = "
   Documento in allegato
   ------------
   medaT for Icop"        
           LogEvent.send_mail(docH, 'MAIL_DOC', TabConfig.get_notes('EMAIL', 'ACTIVITY', 'DAILY_CLI').to_s,           
                     "Invio documento #{docH.doc_type.name} - #{docH.nr_seq}/#{docH.nr_anno}", text_email,
                     {attachments: [
                                     {file_name: docH.doc_file_file_name, file_path: docH.doc_file.path('original')}
                                   ]})
           return true        
       end
      rescue => exception  
       #logger.info exception.backtrace
        puts exception.backtrace #RIMUOVEREEEEEEEEEEEEEEEE
       return false
      end          
  end
  
  
  
  
  
  #CUST_INSPECTION (DETT_CONTAINERS)
  def activity_exec_or_confirmed_in_date
    items = ActivityDettContainer.eager_load(:activity).preload(:activity_op, :shipowner)
           .where("(activities.status IS NULL OR activities.status <> 'ANN') AND (activity_dett_containers.status IS NULL or activity_dett_containers.status <> 'ANN')")
           .where("activity_dett_containers.execution_at IS NOT NULL or activity_dett_containers.confirmed_at IS NOT NULL")
           .where("activities.customer_id IS NOT NULL")
           .where("activity_dett_containers.doc_h_notifica_id IS NULL")
               
  end

  
  #NO CUST_INSPECTION
  def activity_exec_or_confirmed_in_date_from_actvities
    items = Activity
           .joins("LEFT OUTER JOIN activity_types ON activity_types.id = activities.activity_type_id")
           .where("(activities.status IS NULL OR activities.status <> 'ANN')")
           .where("activity_type_id is null OR activity_types.code != 'CUST_INSPECTION'")
           .where("doc_h_notifica_id IS NULL")
           .where("execution_at IS NOT NULL")  
  end
  
  
  
  
  ### UTILITY ####
  def set_0_before_date(date_to)
    
    #ActivityDettContainer.joins(:activity)
    #  .where("activity_dett_containers.execution_at < ? or activity_dett_containers.confirmed_at < ?", date_to, date_to)
    #  .where("activities.customer_id IS NOT NULL")
    #  .where("activity_dett_containers.doc_h_notifica_id IS NULL")
    #  .update_all(doc_h_notifica_id: 0)
    
    Activity
      .joins("LEFT OUTER JOIN activity_types ON activity_types.id = activities.activity_type_id")
      .where("activity_type_id is null OR activity_types.code != 'CUST_INSPECTION'")
      .where("execution_at IS NOT NULL")
      .where("doc_h_notifica_id IS NULL")
      .update_all(doc_h_notifica_id: 0)               
  end
  
    
end