class ShipPrepareItem < ActiveRecord::Base
  belongs_to   :ship_prepare
  belongs_to   :import_header
  belongs_to   :ship_prepare_op
  
  def self.as_json_prop()
      return {
        :include=>{
             :import_header  => {},
             :ship_prepare_op  => {},  
         },
        :methods => [:out_item_status, :out_qty, :out_to_weigh, :display_moved_info]
       }
  end     

  
  def out_item_status
    return self.import_header.count_by_status if self.import_header
    return self.display_moved_info if self.item_type == 'OP'
  end

  def out_qty
    return self.import_header.import_items.count  if self.import_header
    return self.qty
  end
  
  def out_to_weigh
    return 'Si' if self.to_weigh == true
  end

  
  def display_moved_info
    return '' if self.moved_at.nil?
    
    created_user = User.find(self.moved_by_user_id) rescue created_user = User.new    
    ret = ''
    ret += "#{self.moved_at.strftime("%d/%m/%y %H:%M")} by #{created_user.name.to_s}"   
    return ret
  end
  
  
    
end
