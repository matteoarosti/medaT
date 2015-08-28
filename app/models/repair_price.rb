class RepairPrice < ActiveRecord::Base
  
  belongs_to :repair_processing
  belongs_to :shipowner
  
  scope :extjs_default_scope, -> {}
    
  def self.as_json_prop()
      return {
         :include=>{
            :repair_processing => {},
            :shipowner => {:only => [:name]}
            },
         :methods=>[:repair_processing_name]
         }
  end

  
  def repair_processing_name
    [ self.repair_processing.repair_component.description_it, 
      self.repair_processing.repair_position.description_it, 
      self.repair_processing.description_it].join(' | ')
  end

  
end
