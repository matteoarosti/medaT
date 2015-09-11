class RepairHandlingItem < ActiveRecord::Base
  
  belongs_to :handling_item
  has_one :handling_header, through: :handling_item
  
  
  #ho concluso tutte le fasi della riparazione
  def is_all_completed
    return false if self.in_garage_at.nil? ||
                   self.estimate_at.nil? ||
                   self.estimate_authorized_at.nil? ||
                   self.repair_completed_at.nil? ||
                   self.out_garage_at.nil?
    
    return true #todo
  end
  
  def set_close
    self.repair_status = 'CLOSE'
    self.save!
    
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
  
  def self.create_from_hi(hi)
    rhi = RepairHandlingItem.new
     rhi.handling_item_id = hi.id
     rhi.repair_status = 'OPEN'
     rhi.in_garage_at      = hi.datetime_op
     rhi.in_garage_user_id = hi.created_user_id     
    rhi.save!
    rhi
  end
  
  #elenco operazione ammesse/non ammesse
  def enable_operations_list
    ret = {}
    ret[:in_garage_modify] = self.estimate_at.nil? ? true : false      
    ret[:estimate_modify] = self.estimate_at.nil? ? true : false      
    ret[:estimate_request_modify] = !self.estimate_at.nil? && self.estimate_authorized_at.nil? ? true : false
    ret[:estimate_authorized_modify] = self.estimate_authorized_at.nil? && !self.estimate_at.nil? ? true : false
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
  def estimate_authorized_user_name
    User.find(self.estimate_authorized_user_id).name if User.find(self.estimate_authorized_user_id) rescue nil
  end
  def repair_completed_user_name
    User.find(self.repair_completed_user_id).name if User.find(self.repair_completed_user_id) rescue nil
  end
  def out_garage_user_name
    User.find(self.out_garage_user_id).name if User.find(self.out_garage_user_id) rescue nil
  end

  
  def self.as_json_prop()
      return {
        :methods => [:in_garage_user_name, :estimate_user_name, :estimate_authorized_user_name, :repair_completed_user_name, :out_garage_user_name], 
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