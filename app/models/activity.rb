class Activity < ActiveRecord::Base
  belongs_to :customer
  belongs_to :activity_op
  belongs_to :terminal
  belongs_to :shipowner
  belongs_to :activity_type
  has_many   :activity_dett_containers
  
  def self.as_json_prop()
      return { 
        :include=>{
           :customer  => {},
           :shipowner => {},
           :activity_type => {},
           :terminal => {},
           :activity_op => {:only=>[:name, :default_price]}
           }
         }       
  end     
  
  def is_activity(activity_type_code)
    if !self.activity_type.nil? && self.activity_type.code == activity_type_code
      return true
    else
      return false
    end
  end
  
  def status_get_data_json
   [
    {:cod=>'ANN', :descr=>'Richiesta annullata'},
    {:cod=>'OPEN', :descr=>'Open'},
    {:cod=>'CLOSE', :descr=>'Close'}
   ] 
  end 
  
end
