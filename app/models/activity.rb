class Activity < ActiveRecord::Base
  belongs_to :customer
  
  def self.as_json_prop()
      return { 
        :include=>{
           :customer  => {}
           }
         }       
  end     

  
end
