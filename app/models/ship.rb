class Ship < ActiveRecord::Base

 belongs_to :shipowner
 has_many :bookings
 has_many :handling_items
 has_many :import_headers
 has_many :to_do_items
 has_many :ship_prepares
 
   
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
