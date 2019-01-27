class ActivityDettContainer < ActiveRecord::Base
  belongs_to :activity
  has_one :activity_op, through: :activity
  has_one :shipowner, through: :activity
  
  scope :extjs_default_scope, -> {}     

    
  def self.as_json_prop()
      return {
         :include=>{
           :activity  => {include: {activity_op: {}, shipowner: {}}} 
         }
       }
  end     
    
end
