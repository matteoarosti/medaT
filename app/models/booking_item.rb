class BookingItem < ActiveRecord::Base
 belongs_to :booking
 belongs_to :equipment
  
 scope :forBookingId, ->(booking_id) {where("booking_id = ?", booking_id)}
 
  def equipment_id_Name
   self.equipment.equipment_type if self.equipment
  end


  def quantity_used
   self.booking.get_num_impegni(self.id)
  end
  
   
  def self.as_json_prop()
      return {
         :include=>{:equipment => {:only=>[:equipment_type]}},
         :methods => [:equipment_id_Name, :quantity_used]
       }
  end
  

  def self.get_by_booking_eq(booking_id, equipment)
   BookingItem.where('booking_id = ? AND equipment_id = ?', booking_id, equipment).first
  end
  
  
  def self.get_by_num_eq(num, equipment)
   BookingItem.joins(:booking).where('bookings.num_booking = ? AND equipment_id = ?', num, equipment).first
  end

  
 
end