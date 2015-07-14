class InspectionType < ActiveRecord::Base
  
  def self.get_data_json
    items = self.limit(1000)    
  end
  
end
