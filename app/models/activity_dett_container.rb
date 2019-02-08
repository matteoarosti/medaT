class ActivityDettContainer < ActiveRecord::Base
  belongs_to :activity
  has_one :activity_op, through: :activity
  has_one :shipowner, through: :activity
  
  scope :extjs_default_scope, -> {}     

    
  def self.num_pending
    self.joins(:activity)
    .where("(activities.status IS NULL OR activities.status <> 'ANN') AND (activity_dett_containers.status IS NULL or activity_dett_containers.status <> 'ANN')")
    .where("activity_dett_containers.confirmed_at IS NULL AND activities.expiration_date < ? ", Time.zone.yesterday)
    .count
  end  
    
    
  def self.as_json_prop()
      return {
         :include=>{
           :activity  => {
              include: {activity_op: {}, shipowner: {}, customer: {only: 'name'}},
              :methods => [:created_user_name]
           }
         }
       }
  end     
  
  def self.default_scope
    Activity::default_scope
  end
    
end
