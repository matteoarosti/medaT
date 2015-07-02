class Booking < ActiveRecord::Base

 belongs_to :handling_header
 belongs_to :shipowner
 belongs_to :equipment
 belongs_to :ship
 
 has_many :booking_items, :dependent => :destroy
 has_many :handling_headers

 scope :like_num_booking, ->(num_booking) {where("num_booking LIKE ?", "%#{num_booking}%")}
 scope :to_check, ->() {where("to_check = true")}
 scope :not_closed, -> {where("status <> ?", 'CLOSE')}
 
 
#gestione permessi in base a utente
def self.default_scope
  if !User.current.nil? && !User.current.shipowner_flt.blank?
   if User.current.shipowner_flt.include?(',')
     return self.where("shipowner_id IN (#{User.current.shipowner_flt})")
   else
     return self.where("shipowner_id = ?", User.current.shipowner_flt)
   end
  end
  return nil
end
 
 
 
 
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
 
 
def status_get_data_json
 [
  {:cod=>'OPEN', :descr=>'Open'},
  {:cod=>'CLOSE', :descr=>'Close'}
 ] 
end  
 
 def self.get_by_num(num)
  Booking.where('num_booking = ?', num).first
 end
 
 
 
#valori per combo
def status_get_data_json
 [
  {:cod=>'OPEN', :descr=>'Open'},
  {:cod=>'CLOSE', :descr=>'Close'}
 ]
end 


#valido l'inserimento di un nuovo movimento nel booking
# - verifico che non abbia superato la data di scadenza del booking (expiration)
# - verifico che compagnia e equipment siano gli stessi tra handling_header e booking
# - verifico di non aver superato il numero (quantita') indicato nel booking
def valida_insert_item(hi)
 ret = {}
     
 #controllo lo stato del booking
 if !self.expiration.blank? && self.expiration  < Date.today
   ret[:is_valid] = false
   ret[:message]  = 'Il booking e\' scaduto'
   return ret
 end
 
 #controllo lo stato del booking
 if self.status != 'OPEN' || hi.booking_item.status != 'OPEN'
   ret[:is_valid] = false
   ret[:message]  = 'Il booking non e\' in stato OPEN'
   return ret
 end 
 
 #controllo compagnia
 if hi.handling_header.shipowner_id != self.shipowner_id
   ret[:is_valid] = false
   ret[:message]  = 'La compagnia impostata nel booking e nella testata del movimento non coincidono'
   return ret
 end 
 
## NON CONTROLLO PIU', PERCHE' L'ABBINAMENTO VIENE FATTO DIRETTAMENTE CON BookingItem (quindi se non combacia non lo trova)
 #controllo equipment
# if hi.handling_header.equipment_id != self.equipment_id
#   ret[:is_valid] = false
#   ret[:message]  = 'Il tipo di container (equipment) impostato nel booking e nella testata del movimento non coincidono'
#   return ret
# end 
 
 #controllo su quantita' booking (escludendo la testata in corso nel caso di salvataggi)
 num_impegni_booking = self.get_num_impegni(hi.booking_item.id, hi.handling_header.id)
 if hi.booking_item.quantity <= num_impegni_booking
   ret[:is_valid] = false
   ret[:message]  = "Booking pieno, impossibile assegnare altro movimento (q: #{hi.booking_item.quantity}, imp: #{num_impegni_booking})"
   return ret 
 end
 
 ret[:is_valid] = true
 ret[:message]  = ''
 return ret 
end



#num_impegni per booking
def get_num_impegni_tot()
 return HandlingHeader.where('1 = 1').where('booking_id = ?', self.id).count  
end


#num_impegni su booking (escludendo eventualmente un header_handling)
def get_num_impegni(booking_item_id, escludi_header_id = 0)
 hh_count = HandlingHeader.where('1 = 1').where('booking_item_id = ?', booking_item_id)
 hh_count = hh_count.where('id <> ?', escludi_header_id) if (escludi_header_id != 0)
 return hh_count.count  
end



#gestisto lo status (OPEN/CLOSE) in base al numero di movimenti abbinagi
def refresh_status(bi)
 message = nil
 bi.quantity > self.get_num_impegni(bi) ? new_status = 'OPEN' : new_status = 'CLOSE'
 if bi.status != new_status
  bi.status = new_status
  bi.save!
  message = "Lo stato del booking/equipment e' stato modificato in #{new_status}"
 end
 
 return {:message => message}
 
end
 
 
end
