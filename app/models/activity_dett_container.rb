class ActivityDettContainer < ActiveRecord::Base
  belongs_to :activity
  has_one :activity_op, through: :activity
  has_one :shipowner, through: :activity
  belongs_to :doc_h_notifica, class_name: "DocH"
  
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
         },
         :methods => [:confirmed_user_name, :execution_user_name]
       }
  end     
  
  def self.default_scope
    Activity::default_scope
  end
  

  def make_available_user_name
    u = User.find(self.make_available_user_id) rescue u = nil
    return u.name if !u.nil?
    self.make_available_user_id
  end
  
    
  def execution_user_name
    u = User.find(self.execution_user_id) rescue u = nil
    return u.name if !u.nil?
    self.execution_user_id
  end
  
  
 def confirmed_user_name
   u = User.find(self.confirmed_user_id) rescue u = nil
   return u.name if !u.nil?
   self.confirmed_user_id
 end
 
 def dra_out
   if self.doc_h_notifica
     anno_short = self.doc_h_notifica.nr_anno - 2000
     return "DRA: #{self.doc_h_notifica.nr_seq}/'#{anno_short}"
   end
 end
  
    
end
