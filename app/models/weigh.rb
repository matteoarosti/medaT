class Weigh < ActiveRecord::Base
  belongs_to :terminal
  belongs_to :handling_item  

  has_attached_file :scan_file, 
      path: ":rails_root/record_images/:class/:attachment/:id_partition/:style/:filename",
      url: "weighs/download_file/:id"
  # Validate content type, filename, size
  validates_attachment_content_type :scan_file, content_type: /\Aimage/
  validates_attachment_file_name :scan_file, matches: [/png\Z/, /jpe?g\Z/]
  validates_attachment :scan_file, size: { in: 0..1024.kilobytes }
##  do_not_validate_attachment_file_type :scan_file
    
  scope :extjs_default_scope, -> {}
  
  #gestione permessi in base a utente
  def self.default_scope

    if !User.current.nil? && !User.current.terminal_flt.blank?
     if User.current.terminal_flt.include?(',')
       return self.where("terminal_id IN (#{User.current.terminal_flt})")
     else
       return self.where("terminal_id = ?", User.current.terminal_flt)
     end
    end

    if !User.current.nil? && !User.current.shipowner_flt.blank?
     if User.current.shipowner_flt.include?(',')
       return self.where("shipowner_id IN (#{User.current.shipowner_flt})")
     else
       return self.where("shipowner_id = ?", User.current.shipowner_flt)
     end
    end
    
        
    return nil
  end

  
  def self.as_json_prop()
      return {
        :methods => [:in_garage_user_name, :estimate_user_name, :estimate_sent_user_name, :estimate_authorized_user_name, :repair_completed_user_name, :out_garage_user_name], 
        :include=>{
           :terminal  => {}
           }
         }       
  end     
  
  
end
