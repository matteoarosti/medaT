class Booking < ActiveRecord::Base

 belongs_to :shipowner
 belongs_to :equipment

 scope :like_num_booking, ->(num_booking) {where("num_booking LIKE ?", "%#{num_booking}%")}
 
 def shipowner_id_Name
  self.shipowner.name if self.shipowner
 end
 
 def equipment_id_Name
  self.equipment.sizetype if self.equipment
 end
 
  def self.as_json_prop()
     return {
        :include=>{:shipowner => {:only=>[:name]}, :equipment => {:only=>[:size]}},
        :methods => [:shipowner_id_Name, :equipment_id_Name]
      }
 end
 
end
