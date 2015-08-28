class RepairComponent < ActiveRecord::Base
  
  scope :extjs_default_scope, -> {}

    
  def self.combo_displayField
   'description_it'
  end
   
end
