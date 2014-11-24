class ImportItem < ActiveRecord::Base


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
