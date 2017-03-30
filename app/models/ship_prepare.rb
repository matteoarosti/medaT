class ShipPrepare < ActiveRecord::Base
  
  belongs_to :customer
  belongs_to :ship
  has_many   :ship_prepare_items
  
  def self.as_json_prop()
      return { 
        :include=>{
           :customer  => {},
           :ship  => {}
           }
         }       
  end     

end
