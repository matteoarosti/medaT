class ImportItem < ActiveRecord::Base

  belongs_to :equipment
  belongs_to :import_header
  belongs_to :shipowner

 def equipment_id_Name
  self.equipment.sizetype if self.equipment
 end  
 
 def shipowner_id_Name
   self.shipowner.name if self.shipowner
 end  
   
 
 #se e' ancora da importare, ricerco l'eventuale handling_header non chiuso per il container
 def open_handling_header_id
   hh = HandlingHeader.not_closed.container(self.container_number).first
   return hh.id unless hh.nil?
   return nil 
 end

 def open_handling_header_rec
    hh = HandlingHeader.not_closed.container(self.container_number).first
    return hh unless hh.nil?
    return nil 
 end
 
  
 def self.as_json_prop()
     return {
        :methods => [:equipment_id_Name, :shipowner_id_Name, :open_handling_header_id, :open_handling_header_rec]
      }
 end 

  def self.AddRecord(import_header_id, shipowner_id, container_number, container_status, equipment_id, weight, temperature, imo, booking)
    ImportItem.create(:import_header_id => import_header_id,
                      :shipowner_id => shipowner_id,
                      :container_number => container_number,
                      :container_status => container_status,
                      :equipment_id => equipment_id,
                      :weight => weight,
                      :temperature => temperature,
                      :imo => imo,
                      :num_booking => booking
    )
  end

end
