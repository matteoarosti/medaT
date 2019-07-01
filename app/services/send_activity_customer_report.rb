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
  
  
  def send_doc_email(docH)
      begin
       if !docH.customer.nil?
           text_email = "
   Documento in allegato
   ------------
   medaT for Icop"        
           LogEvent.send_mail(docH, 'MAIL_DOC', ['matteo.arosti@gmail.com'], 
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
  
  
  
  def activity_exec_or_confirmed_in_date
    items = ActivityDettContainer.eager_load(:activity).preload(:activity_op, :shipowner)
           .where("(activities.status IS NULL OR activities.status <> 'ANN') AND (activity_dett_containers.status IS NULL or activity_dett_containers.status <> 'ANN')")
           .where("confirmed_at IS NOT NULL or confirmed_at IS NOT NULL")
           .where("activities.customer_id IS NOT NULL")
           #.where("doc_h_notifica_id IS NULL")
               
  end
  
end