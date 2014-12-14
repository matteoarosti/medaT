class Port < ActiveRecord::Base

scope :extjs_default_scope, -> {}


  def self.combo_displayField
   'city'
  end
  
end
