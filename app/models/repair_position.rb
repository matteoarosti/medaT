class RepairPosition < ActiveRecord::Base

  has_many :repair_processings
  has_many :repair_prices, through: :repair_processings
    
  scope :extjs_default_scope, -> {} 
  
    
  def self.combo_displayField
   'description_it'
  end
    
end
