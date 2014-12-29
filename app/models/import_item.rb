class ImportItem < ActiveRecord::Base

  belongs_to :equipment
  belongs_to :import_header

 def equipment_id_Name
  self.equipment.sizetype if self.equipment
 end  
 
 def self.as_json_prop()
     return {
        :methods => :equipment_id_Name
      }
 end 

  def self.AddRecord(import_header_id, shipowner_id, container_number, container_status, equipment_id, weight, temperature, imo)
    ImportItem.create(:import_header_id => import_header_id,
                      :shipowner_id => shipowner_id,
                      :container_number => container_number,
                      :container_status => container_status,
                      :equipment_id => equipment_id,
                      :weight => weight,
                      :temperature => temperature,
                      :imo => imo)
  end

end
