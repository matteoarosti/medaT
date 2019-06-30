class SendActivityCustomerReport
  
  #preparo, per ogni cliente, pdf da inviare con resconto attivita' del giorno  
  def call
    #per og ni cliente
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
  
  
  
  def activity_exec_or_confirmed_in_date
    items = ActivityDettContainer.eager_load(:activity).preload(:activity_op, :shipowner)
           .where("(activities.status IS NULL OR activities.status <> 'ANN') AND (activity_dett_containers.status IS NULL or activity_dett_containers.status <> 'ANN')")
           .where("confirmed_at IS NOT NULL or confirmed_at IS NOT NULL")
           .where("doc_h_notifica_id IS NULL")
           .where("activities.customer_id IS NOT NULL")    
  end
  
end