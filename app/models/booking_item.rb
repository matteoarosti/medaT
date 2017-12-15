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
  
  
  #creo un array con i vari stati (quanti ne ho in terminal, quanti sono gia' stati imbarcati, ...)
  def get_by_last_dett()
    ret = {}
    hhs = HandlingHeader.where('1 = 1').where('booking_item_id = ?', self.id)
    hhs.each do |hh|
      if hh.handling_status == 'CLOSE'
        ret[:close] = ret[:close].to_i + 1
      else
        last_dett = hh.last_dett
        ret[last_dett.handling_item_type] = ret[last_dett.handling_item_type].to_i + 1 
      end
    end #for each
   return ret
  end
  
  def out_by_last_dett()
    ret = []
    by_last_dett = self.get_by_last_dett()
    by_last_dett.each do |bisk, bisv|
      ret << "<br/>#{bisk} #{bisv}"
    end
    ret.join()
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

  
 
def ventilation_get_data_json
 [
  {:cod=>nil,       :descr=>'- Non specificato -'},
  {:cod=>'NORMAL',  :descr=>'Normale'},
  {:cod=>'AUTO',    :descr=>'Automatico'}
 ] 
end  
  

end