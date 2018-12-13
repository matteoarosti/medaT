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
           :activity_op => {:only=>[:name, :default_price]},
           :activity_dett_containers => {:only => [:container_number, :status, :make_available_at, :execution_at]}
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
