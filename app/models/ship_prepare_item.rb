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
        :methods => [:out_item_status, :out_qty]
       }
  end     

  
  def out_item_status
    return self.import_header.count_by_status if self.import_header
  end

  def out_qty
    return self.import_header.import_items.count  if self.import_header
    return self.qty
  end

    
end
