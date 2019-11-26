class Activity < ActiveRecord::Base
  belongs_to :customer
  belongs_to :activity_op
  belongs_to :terminal
  belongs_to :shipowner
  belongs_to :activity_type
  has_many   :activity_dett_containers
  
  
  has_attached_file :scan_file, 
      path: ":rails_root/record_images/:class/:attachment/:id_partition/:style/:filename",
      url: "activities/download_file/:id"
  # Validate content type, filename, size
  #validates_attachment_content_type :scan_file, content_type: /\Aimage/
  validates_attachment_content_type :scan_file, content_type: ["application/pdf", /\Aimage\/.*\Z/]
  #validates_attachment_file_name :scan_file, matches: [/png\Z/, /jpe?g\Z/]
  validates_attachment :scan_file, size: { in: 0..2048.kilobytes }
  do_not_validate_attachment_file_type :scan_file
  
  
  def self.as_json_prop()
      return { 
        :include=>{
           :customer  => {},
           :shipowner => {},
           :activity_type => {},
           :terminal => {},
           :activity_op => {:only=>[:name, :default_price, :recalculate_gest_price]},
           :activity_dett_containers => {
                :only => [:container_number, :status, :make_available_at, :execution_at, :confirmed_at],
                :methods => [:dra_out]}
           }
           },
         :methods => [:created_user_name]
         }       
  end     
  
  
  def created_user_name
    u = User.find(self.created_user_id) rescue u = nil
    return u.name if !u.nil?
    self.created_user_id
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
  
  
  #gestione permessi in base a utente
  def self.default_scope

    if !User.current.nil? && !User.current.terminal_flt.blank?
     if User.current.terminal_flt.include?(',')
       return self.where("activities.terminal_id IN (#{User.current.terminal_flt})")
     else
       return self.where("activities.terminal_id = ?", User.current.terminal_flt)
     end
    end

    if !User.current.nil? && !User.current.shipowner_flt.blank?
     if User.current.shipowner_flt.include?(',')
       return self.where("activities.shipowner_id IN (#{User.current.shipowner_flt})")
     else
       return self.where("activities.shipowner_id = ?", User.current.shipowner_flt)
     end
    end

    if !User.current.nil? && !User.current.customer_flt.blank?
     if User.current.customer_flt.include?(',')
       return self.where("activities.customer_id IN (#{User.current.customer_flt})")
     else
       return self.where("activities.customer_id = ?", User.current.customer_flt)
     end
    end

        
    return nil
  end  
  
end
