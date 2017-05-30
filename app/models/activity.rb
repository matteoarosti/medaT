class Activity < ActiveRecord::Base
  belongs_to :customer
  belongs_to :activity_op
  
  def self.as_json_prop()
      return { 
        :include=>{
           :customer  => {},
           :activity_op => {:only=>[:name]}
           }
         }       
  end     
  
end
