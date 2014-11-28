class HandlingItem < ActiveRecord::Base
 belongs_to :handling_header
 belongs_to :ship
 belongs_to :carrier
 
 scope :extjs_default_scope, -> {}
 scope :handlingHeader, ->(handling_header) {where("handling_header_id = ?", handling_header)}
 
 before_create :set_by_item_type
 
 def set_by_item_type()    
 end
 
 
################################################################   
#per decodifica chiavi in extjs_scaffold
################################################################   
 def ship_id_Name
  self.ship.name if self.ship
 end
 def carrier_id_Name
  self.carrier.name if self.carrier
 end 
 
 def self.as_json_prop()
     return {
        :methods => [:ship_id_Name, :carrier_id_Name]
      }
 end 
 
 
 
 
end
