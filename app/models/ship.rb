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

 def self.get_id_by_name(name)
   Ship.where(:name => name).first.id
 end

end
