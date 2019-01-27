class RepairHandlingItem < ActiveRecord::Base
  
  belongs_to :handling_item
  has_one :handling_header, through: :handling_item
  has_many :repair_estimate_items, :dependent => :destroy
  has_one :equipment, through: :handling_header
  has_one :shipowner, through: :handling_header
  belongs_to :pti_type_requested, :class_name => 'PtiType'
  belongs_to :pti_type_confirmed, :class_name => 'PtiType'
  
  
  #ho concluso tutte le fasi della riparazione
  def is_all_completed
    return false if self.in_garage_at.nil? ||
                   self.estimate_at.nil? ||
                   self.estimate_sent_at.nil? ||
                   self.estimate_authorized_at.nil? ||
                   self.repair_completed_at.nil? ||
                   self.out_garage_at.nil?
    
    return true #todo
  end
  
  def set_close
    self.repair_status = 'CLOSE'
    self.save!
    
    if self.disabled_wf_on_close == true
      return {:success => true}
    end
    
    #accodo 'REPAIR' in hh
      hh = self.handling_item.handling_header
      hi = hh.handling_items.new()
      hi.datetime_op = Time.now
      hi.handling_item_type = "REPAIR"
      
      #se supera i vari controlli salvo il dettalio e aggiorno la testata
      validate_insert_item = hh.validate_insert_item(hi)
      if validate_insert_item[:is_valid]
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
  
  def self.create_from_hi(hi, p = {})
        
#    if hi.handling_header.shipowner.repair_active == true
      #al monento non serve, perche' per le ditte non richieste non vengono proprio dichiarati i dannieggiati.
      #Se poi cressero i danneggiati come farebbero a metterli riparati? 
      rhi = RepairHandlingItem.new
       rhi.handling_item_id = hi.id
       rhi.repair_status = 'OPEN'
       rhi.in_garage_at      = hi.datetime_op
       rhi.in_garage_user_id = hi.created_user_id
              
       if !p[:pti_type_requested_id].nil?
        #viene richiesto un PTI... momorizzo il tipo di PTI richiesto ... 
        rhi.pti_type_requested_id = p[:pti_type_requested_id]
        rhi.save!
        
        #... creo gia' la riga di preventivo associata a PTI_type
        pt = PtiType.find(p[:pti_type_requested_id])
        rhi.add_repair_estimate_item(pt.repair_processing_id)
        
        #confermo gia' la redazione del preventivo
         rhi.estimate_at = Time.zone.now
         rhi.estimate_user_id = User.current.id         
         rhi.calculate_total_on_estimate
         rhi.save!
       end
            
      rhi.save!
            
      # se passate (in fase di ispezione) creo gia' le righe legate al preventivo - LAVORAZIONI INTERNE
      if !p[:ar_op_int].nil?
        p[:ar_op_int].each do |c|
          rhi.add_repair_estimate_item(c[:repair_processing_id], c[:qty], nil, nil, true)
        end
      end
      
      # se passate (in fase di ispezione) creo gia' le righe legate al preventivo - LAVORAZIONI OFFICINA
      if !p[:ar_op_off].nil?
        p[:ar_op_off].each do |c|
          rhi.add_repair_estimate_item(c[:repair_processing_id], c[:qty])
        end
      end      
      
      rhi
#    end
  end
  
  #elenco operazione ammesse/non ammesse
  def enable_operations_list
    ret = {}
    ret[:in_garage_modify] = self.estimate_at.nil? ? true : false      
    ret[:estimate_modify] = self.estimate_at.nil? || User.current.admin_can?(:repair, :always_modify) ? true : false      
    ret[:estimate_request_modify] = !self.estimate_at.nil? && self.estimate_authorized_at.nil? ? true : false
    ret[:estimate_sent_modify] = !self.estimate_at.nil? && (self.estimate_sent_at.nil? ? true : false) && User.current.admin_can?(:repair, :table)    
    ret[:estimate_authorized_modify] = self.estimate_authorized_at.nil? && !self.estimate_at.nil? && (!self.estimate_sent_at.nil? ? true : false) && User.current.admin_can?(:repair, :table)
    ret[:repair_completed_modify] = !self.estimate_at.nil? && self.repair_completed_at.nil? ? true : false
    ret[:out_garage_modify] = !self.repair_completed_at.nil? && self.out_garage_at.nil? ? true : false
    ret
  end
  
  
  def in_garage_user_name
    User.find(self.in_garage_user_id).name if User.find(self.in_garage_user_id) rescue nil
  end
  def estimate_user_name
    User.find(self.estimate_user_id).name if User.find(self.estimate_user_id) rescue nil
  end
  def estimate_sent_user_name
    User.find(self.estimate_sent_user_id).name if User.find(self.estimate_sent_user_id) rescue nil
  end
  def estimate_authorized_user_name
    User.find(self.estimate_authorized_user_id).name if User.find(self.estimate_authorized_user_id) rescue nil
  end
  def repair_completed_user_name
    User.find(self.repair_completed_user_id).name if User.find(self.repair_completed_user_id) rescue nil
  end
  def out_garage_user_name
    User.find(self.out_garage_user_id).name if User.find(self.out_garage_user_id) rescue nil
  end

  
  def calculate_total_on_estimate
    tot_provider = tot_customer = 0
    self.repair_estimate_items.each do |r|
      if r.confirmed != false
        tot_provider += r.quantity.to_f * r.provider_time.to_f * r.provider_hourly_cost.to_f
        tot_provider += r.quantity.to_f * r.provider_material_price.to_f
        tot_customer += r.quantity.to_f * r.customer_time.to_f * r.customer_hourly_cost.to_f
        tot_customer += r.quantity.to_f * r.customer_material_price.to_f
      end
    end
    self.total_cost_provider_estimate = tot_provider
    self.total_cost_customer_estimate = tot_customer
  end
  

  def calculate_total_on_authorized
    tot_provider = tot_customer = 0
    self.repair_estimate_items.each do |r|
      if r.confirmed != false
        tot_provider += r.quantity.to_f * r.provider_time.to_f * r.provider_hourly_cost.to_f
        tot_provider += r.quantity.to_f * r.provider_material_price.to_f
        tot_customer += r.quantity.to_f * r.customer_time.to_f * r.customer_hourly_cost.to_f
        tot_customer += r.quantity.to_f * r.customer_material_price.to_f
      end
    end
    self.total_cost_provider_authorized = tot_provider
    self.total_cost_customer_authorized = tot_customer
  end

    
 def pti_type_requested_name
   pti_type_requested.name unless pti_type_requested.nil?
 end 
 def pti_type_confirmed_name
   pti_type_confirmed.name unless pti_type_confirmed.nil?
 end
 
 def add_repair_estimate_item(repair_processing_id, quantity = 1, side = nil, notes = nil, op_int = false)
   repair_price = RepairPrice.where("repair_processing_id=?", repair_processing_id).where("shipowner_id=?", self.handling_item.handling_header.shipowner_id).first
   return false if !repair_price
   n = self.repair_estimate_items.new
       
   #memorizzo i costo orari
   n.is_internal = op_int
   if op_int #operazione eseguita internamente... azzero tutti i costi del provider (officina)
     repair_price.provider_time = 0
     repair_price.provider_material_price = 0
     n.provider_hourly_cost = 0
   else  
     n.provider_hourly_cost = self.handling_item.handling_header.shipowner.estimate_hourly_cost_provider     
   end
   
   n.customer_hourly_cost = self.handling_item.handling_header.shipowner.estimate_hourly_cost_customer
   
   n.repair_processing_id = repair_processing_id
   n.quantity = quantity
   n.side     = side
   n.provider_notes = notes   
      
   n.set_auto_data(repair_price)          
   n.save!   
 end
 
 
  
  def self.as_json_prop()
      return {
        :methods => [:in_garage_user_name, :estimate_user_name, :estimate_sent_user_name, :estimate_authorized_user_name, :repair_completed_user_name, :out_garage_user_name,
                     :pti_type_requested_name, :pti_type_confirmed_name], 
        :include=>{
           :handling_header  => {
             :include => {
               :shipowner => {:only=>[:name]},
               :equipment => {:only=>[:equipment_type]}
             }
            }
           }
         }       
  end     
  
  
  
end
