class RepairPrice < ActiveRecord::Base
  
  belongs_to :repair_processing
  belongs_to :shipowner
  
  scope :extjs_default_scope, -> {}
    
  def self.extjs_sc_list_add_default_join_on_my_filters(rel)
      rel.joins(:repair_processing)
  end  
    
    
  def self.as_json_prop()
      return {
         :include=>{
            :repair_processing => {},
            :shipowner => {:only => [:name, :short_name]}
            },
         :methods=>[:repair_processing_name, :repair_processing_description]
         }
  end

  
  def repair_processing_description
   if self.repair_processing.nil?
    return '#PROC_DELETE#'
   else 
    return self.repair_processing.description_it.to_s
   end   
  end

  
  def repair_processing_name
   if self.repair_processing.nil?
   	return '#PROC_DELETE#'
   else 
    return [ self.repair_processing.repair_position.nil? ? '#DEL#' : self.repair_processing.repair_position.description_it, 
      self.repair_processing.repair_component.nil? ? '#DEL#' : self.repair_processing.repair_component.description_it, 
      self.repair_processing.description_it.to_s].join(' | ')
   end   
  end

  
end
