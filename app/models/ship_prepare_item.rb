class ShipPrepareItem < ActiveRecord::Base
  belongs_to   :ship_prepare
  belongs_to   :import_header
  belongs_to   :ship_prepare_op
  belongs_to   :um
  has_many     :ship_prepare_item_weighs
  
  def self.as_json_prop()
      return {
        :include=>{
             :import_header  => {},
             :ship_prepare_op  => {},  
             :um  => {}
         },
        :methods => [:out_item_status, :out_item_status_ric, :out_qty, :out_to_weigh, :display_moved_info]
       }
  end     

  
  def out_item_status
    return self.import_header.count_by_status if self.import_header
    return self.display_moved_info if self.item_type == 'OP' and !self.to_weigh
    return self.weigh_status if self.item_type == 'OP' and self.to_weigh
  end

  def out_item_status_ric
    return "" if self.import_header
    return self.display_moved_info_ric if self.item_type == 'OP' and !self.to_weigh
    return self.weigh_status_ric if self.item_type == 'OP' and self.to_weigh
  end
  
  
  def weigh_status
    ret = ''
    ret += "<p><span style='font-size:20px; font-weight: bold'>#{ActionController::Base.helpers.number_with_delimiter(ship_prepare_item_weighs.not_ric.sum(:qty).to_i, delimiter: ".")}</span><br/>(#{ship_prepare_item_weighs.not_ric.count} pesata/e)</p>"
    return ret
  end

  def weigh_status_ric
    ret = ''
    ret += "<p><span style='font-size:20px; font-weight: bold'>#{ActionController::Base.helpers.number_with_delimiter(ship_prepare_item_weighs.ric.sum(:qty_ric).to_i, delimiter: ".")}</span><br/>(#{ship_prepare_item_weighs.ric.count} pesata/e)</p>"
    return ret
  end
  
  def out_qty
    return self.import_header.import_items.count  if self.import_header
    return self.qty
  end
  
  def out_to_weigh
    return 'Si' if self.to_weigh == true
  end

  
  def display_moved_info
    ret = ''
    ret += "<p><span style='font-size:20px; font-weight: bold'>#{ActionController::Base.helpers.number_with_delimiter(ship_prepare_item_weighs.sum(:qty).to_i, delimiter: ".")}</span><br/>(#{ship_prepare_item_weighs.not_ric.count} virata/e)</p>"
    return ret    
    
    #return '' if self.moved_at.nil?    
    #created_user = User.find(self.moved_by_user_id) rescue created_user = User.new    
    #ret = ''
    #ret += "#{self.moved_at.strftime("%d/%m/%y %H:%M")} by #{created_user.name.to_s}"   
    #return ret
  end
  
  def display_moved_info_ric
    ret = ''
    ret += "<p><span style='font-size:20px; font-weight: bold'>#{ActionController::Base.helpers.number_with_delimiter(ship_prepare_item_weighs.sum(:qty_ric).to_i, delimiter: ".")}</span><br/>(#{ship_prepare_item_weighs.ric.count} virata/e)</p>"
    return ret    
    
    #return '' if self.moved_at.nil?    
    #created_user = User.find(self.moved_by_user_id) rescue created_user = User.new    
    #ret = ''
    #ret += "#{self.moved_at.strftime("%d/%m/%y %H:%M")} by #{created_user.name.to_s}"   
    #return ret
  end
  
    
end
