class TabNote < ActiveRecord::Base
  scope :extjs_default_scope, -> {}
    
  has_attached_file :attach_file, 
      path: ":rails_root/record_images/:class/:attachment/:id_partition/:style/:filename",
      url: "tab_notes/download_file/:id"
  # Validate content type, filename, size
  validates_attachment_content_type :attach_file, content_type: [/\Aimage/, 'application/pdf']
  validates_attachment_file_name :attach_file, matches: [/png\Z/, /jpe?g\Z/, /pdf\Z/]
  validates_attachment :attach_file, size: { in: 0..3072.kilobytes }    
  
    
  def self.as_json_prop()
      return { 
         :methods => [:attach_absolute_path, :created_user_name]
         }       
  end
    
  
  def created_user_name
    u = User.find(self.created_user_id) rescue u = nil
    return u.name if !u.nil?
    self.confirmed_user_id
  end
  
  
  
  def attach_absolute_path
    self.attach_file.url
  end
    
    
    
=begin   
  def self.get_notes(tab, sez1, sez2 = nil)
    r = self.where(tab: tab, sez1: sez1, sez2: sez2).first
    return r.notes if r
  end
=end  
  
end
