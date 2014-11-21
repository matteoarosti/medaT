class HandlingHeader < ActiveRecord::Base

 belongs_to :shipowner
 belongs_to :equipment
 has_many :handling_items
   
 scope :extjs_default_scope, -> { eager_load(:shipowner, :equipment) }
 scope :container, ->(container_number) {where("container_number = ?", container_number)}







################################################################   
#per decodifica chiavi in extjs_scaffold
################################################################   
 def shipowner_id_Name
  self.shipowner.name if self.shipowner
 end
 def equipment_id_Name
  self.equipment.name if self.equipment
 end 
 
 def self.as_json_prop()
     return {
        :include=>{:shipowner => {:only=>[:name]}, :equipment => {:only=>[:type]}},
        :methods => [:shipowner_id_Name, :equipment_id_Name]
      }
 end     


end
