class Terminal < ActiveRecord::Base

  scope :extjs_default_scope, -> {}
    
  def self.combo_displayField
   'terminal_name'
  end
      
  
end
