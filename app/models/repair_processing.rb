class RepairProcessing < ActiveRecord::Base
  
  belongs_to :repair_position
  belongs_to :repair_component
  
  has_many :repair_prices
  
  scope :extjs_default_scope, -> {}
    
  def self.as_json_prop()
      return {
         :include=>{
            :repair_position => {:only=>[:description_it]},
            :repair_component => {:only=>[:description_it]}
            }
         }
  end
  
  
  def combo_name
    ret = ""
    [self.repair_position.description_it, self.repair_component.description_it, self.description_it].join(' | ')
  end
  
  
  def preparation_time_type_get_data_json
   [
    {:cod=>'ID', :descr=>'Impact Damage'},
    {:cod=>'WT', :descr=>'Wear Time'},
    {:cod=>'CL', :descr=>'Cleaning'}
   ]
  end
 
  
   
end
