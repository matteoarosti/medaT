class HandlingItem < ActiveRecord::Base
 belongs_to :handling_header
 has_one :equipment, through: :handling_header
 has_one :shipowner, through: :handling_header
 has_one :hh_booking, through: :handling_header, source: :booking
 belongs_to :ship
 belongs_to :carrier
 belongs_to :booking
 belongs_to :booking_item
 belongs_to :shipper
 belongs_to :terminal
 belongs_to :inspection_type
 belongs_to :ship_prepare
 belongs_to :pier
 belongs_to :gru
 belongs_to :weigh
 
 
  #interchange relativo al movimento
  has_attached_file :scan_file, 
      path: ":rails_root/record_images/:class/:attachment/:id_partition/:style/:filename",
      url: "handling_headers/hi_download_file/:id"
  # Validate content type, filename, size
  validates_attachment_content_type :scan_file, content_type: /\Aimage/
  validates_attachment_file_name :scan_file, matches: [/pdf\Z/, /png\Z/, /jpe?g\Z/]
  validates_attachment :scan_file, size: { in: 0..2048.kilobytes }

  
 scope :extjs_default_scope, -> {}
 scope :handlingHeader, ->(handling_header) {where("handling_header_id = ?", handling_header)} 
 scope :locked, -> {where("lock_fl=?", true)}
 scope :locked_INSPECT, -> {locked.where("lock_type = ?", 'INSPECT')}
 scope :locked_DAMAGED, -> {locked.where("lock_type IN(?)", ['DAMAGED', 'DAMAGED_AU'])}
 scope :to_be_moved, -> {where("to_be_moved=?", true)}
 scope :not_ship_prepare, -> {where("ship_prepare_id IS NULL")}

 
 before_create :set_by_item_type
  
 
#gestione permessi in base a utente
def self.default_scope
 
  #basta il solo filtro su handling_header (lo aggiunge in automatico nel join). Serve quindi sempre il join 
  #if !User.current.nil? && !User.current.shipowner_flt.blank?
  #    return self.where({handling_headers: {shipowner_id: User.current.shipowner_flt}})
  #end
  
  return nil
end
 
 
 
 def set_by_item_type()    
 end
 
 
 #########################################
 def set_lock(lock_type)
 #########################################   
   self.lock_fl   = true
   self.lock_type = lock_type
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
 def shipper_id_Name
   self.shipper.name if self.shipper
 end
  def terminal_id_Code
    self.terminal.code if self.terminal
  end
  def handling_item_type_short
    ret = I18n.t("operations.#{self.handling_item_type}.short") if !self.handling_item_type.empty?
    ret += '<br>' + self.inspection_type.name if !self.inspection_type.nil? && self.handling_item_type == 'CUST_INSPECTION'
    ret
  end

 def self.as_json_prop()
     return {
        :methods => [:ship_id_Name, :carrier_id_Name, :shipper_id_Name, :terminal_id_Code, :handling_item_type_short]
      }
 end 
 

#a ritroso (nell'handling) verifico se ho un dettaglio di un certo tipo operazione 
def search_hi_by_item_type(item_type)
  self.handling_header.handling_items.where("datetime_op <= ?", self.datetime_op).order("datetime_op desc").each do |hii|
    if hii.datetime_op < self.datetime_op || (hii.datetime_op == self.datetime_op && hii.id <= self.id)
            return hii if hii.handling_item_type == item_type
    end 
  end
  return nil
end 
 
 
  
 #a ritroso (nell'handling) verifico se ho un dettaglio con il booking 
 def search_booking()
   #todo: se trovo un mancato posizionamento non devo considerare il booking assegnato?
   self.handling_header.handling_items.where("datetime_op <= ?", self.datetime_op).order("datetime_op desc").joins(:handling_header).each do |hii|
     if hii.datetime_op < self.datetime_op || (hii.datetime_op == self.datetime_op && hii.id <= self.id)
             return hii.booking if !hii.booking.nil?
     end 
   end
   return nil
 end 

#a ritroso (nell'handling) verifico se ho un dettaglio con il booking_item 
def search_booking_item()
  #todo: se trovo un mancato posizionamento non devo considerare il booking assegnato?
  self.handling_header.handling_items.where("datetime_op <= ?", self.datetime_op).order("datetime_op desc, id desc").joins(:handling_header).each do |hii|
    return hii.booking_item if !hii.booking_item.nil? 
  end
  return nil
end 


#a ritroso (nell'handling) recupero il movimento che ha acceso un certo lock type (es: INSPECT) 
def search_hi_by_lock_type(lock_type)
  self.handling_header.handling_items.where("datetime_op <= ?", self.datetime_op).order("datetime_op desc").each do |hii|
    if hii.datetime_op < self.datetime_op || (hii.datetime_op == self.datetime_op && hii.id <= self.id)
            return hii if hii.lock_fl = true && hii.lock_type == lock_type
    end 
  end
  return nil
end 

#a ritroso (nell'handling) recupero il movimento con un certo operation_type (es: MT) 
def search_hi_by_operation_type(operation_type)
  self.handling_header.handling_items.where("datetime_op <= ?", self.datetime_op).order("datetime_op desc").each do |hii|
    if hii.datetime_op < self.datetime_op || (hii.datetime_op == self.datetime_op && hii.id <= self.id)
            return hii if hii.operation_type == operation_type
    end 
  end
  return nil
end 

 

#is_export: se' ha (a ritroso) il booking abbinato, e' un movimento legato alla fase di export. Altrimenti alla fase di import
def is_import_export()
  b = self.search_booking
  if b.nil?
    return 'I'
  else
    return 'E'
  end
end

 
def rfcon_calculate_dd
  d = (self.datetime_op_end - self.datetime_op).to_f / 60 #diff date in minuti
  d = d - 97  #la prima 1h e 26' sono abbuonati
  d = d / 60  #in ore
  d = d / 24  #diff in giorni
  d = d.to_i
  d+1
end

 
#valori per combo
def container_FE_get_data_json
 [
  {:cod=>'F', :descr=>'Full'},
  {:cod=>'E', :descr=>'Empty'}
 ]
end 
 
#valori per combo
def handling_item_type_get_data_json
 [
  {:cod=>'I_DISCHARGE',   :descr=>'Discharge From Ship'},
  {:cod=>'O_EMPTYING',    :descr=>'Out for Emptying'}
 ]
end 
 
#valori per combo
def load_dischage_get_data_json
 [
  {:cod=>'L',    :descr=>'Imbarco'},
  {:cod=>'D',    :descr=>'Sbarco'}
 ]
end 

############## calcolo fasce prezzo per ship prepare
def price_range
  ShipPrepare.price_range(self.datetime_op)
end

def price_range_val
  self.ship_prepare.price_range_val(self.price_range)
end

 
end
