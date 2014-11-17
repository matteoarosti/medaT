class Ship < ActiveRecord::Base

 belongs_to :shipowner
   
 scope :extjs_default_scope, -> { eager_load(:shipowner) }
   
 def shipowner_id_Name
  self.shipowner.name if self.shipowner
 end
 
 def self.as_json_prop()
     return {
        :include=>{:shipowner => {:only=>[:name]}},
        :methods => :shipowner_id_Name
      }
 end     
  

end
