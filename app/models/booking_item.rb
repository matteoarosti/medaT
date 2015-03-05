class BookingItem < ActiveRecord::Base
 belongs_to :booking
 belongs_to :equipment
  
 scope :forBookingId, ->(booking_id) {where("booking_id = ?", booking_id)}
 
  def equipment_id_Name
   self.equipment.equipment_type if self.equipment
  end

 
  def self.as_json_prop()
      return {
         :include=>{:equipment => {:only=>[:equipment_type]}},
         :methods => :equipment_id_Name
       }
  end

 
end