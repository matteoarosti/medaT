class HandlingItem < ActiveRecord::Base
 belongs_to :handling_header
 belongs_to :ship
 belongs_to :carrier
 belongs_to :booking
 belongs_to :booking_item
 belongs_to :shipper
 belongs_to :terminal
 
 scope :extjs_default_scope, -> {}
 scope :handlingHeader, ->(handling_header) {where("handling_header_id = ?", handling_header)} 
 scope :locked, -> {where("lock_fl=?", true)}
 scope :locked_INSPECT, -> {locked.where("lock_type = ?", 'INSPECT')}
 scope :locked_DAMAGED, -> {locked.where("lock_type = ?", 'DAMAGED')}
 scope :to_be_moved, -> {where("to_be_moved=?", true)}

 
 before_create :set_by_item_type
 
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
    I18n.t("operations.#{self.handling_item_type}.short") if !self.handling_item_type.empty?
  end

 def self.as_json_prop()
     return {
        :methods => [:ship_id_Name, :carrier_id_Name, :shipper_id_Name, :terminal_id_Code, :handling_item_type_short]
      }
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
 
 
end
