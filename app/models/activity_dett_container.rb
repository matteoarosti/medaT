class ActivityDettContainer < ActiveRecord::Base
  belongs_to :activity
  has_one :activity_op, through: :activity
  has_one :shipowner, through: :activity
  belongs_to :doc_h_notifica, class_name: "DocH"
  belongs_to :doc_h_notifica_make_available, class_name: "DocH"
  
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
         :methods => [:confirmed_user_name, :execution_user_name, :dra_out]
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
   if !self.doc_h_notifica_id.nil? && self.doc_h_notifica_id > 0
     anno_short = self.doc_h_notifica.nr_anno - 2000
     ret = "DRA: #{self.doc_h_notifica.nr_seq}/#{anno_short}"
   else
     ret = "NO DRA" 
   end
   
   #messa a dispo
   if !self.doc_h_notifica_make_available_id.nil? && self.doc_h_notifica_make_available_id > 0
     anno_short = self.doc_h_notifica_make_available.nr_anno - 2000
     ret += " (disp.: #{self.doc_h_notifica_make_available.nr_seq}/#{anno_short})"
   end
    
   return ret
 end
  
    
end
