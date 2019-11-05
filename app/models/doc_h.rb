class DocH < ActiveRecord::Base
  
  belongs_to :customer
  belongs_to :doc_type
  
  
  has_attached_file :doc_file, 
      path: ":rails_root/record_images/:class/:attachment/:id_partition/:style/:filename",
      url: "doc_hs/download_file/:id"
  # Validate content type, filename, size
  #validates_attachment_content_type :scan_file, content_type: /\Aimage/
  validates_attachment_content_type :doc_file, content_type: ["application/pdf", /\Aimage\/.*\Z/]
  #validates_attachment_file_name :scan_file, matches: [/png\Z/, /jpe?g\Z/]
  validates_attachment :doc_file, size: { in: 0..4096.kilobytes }
  do_not_validate_attachment_file_type :doc_file
  
  
  def assign_num
    #ToDo: block
    nr = DocNr.find_or_create_by!(doc_type: self.doc_type, nr_anno: Time.current.year) do |r|
      r.last_seq = 0
    end
    
    nr.last_seq+=1
    nr.save!
    
    self.nr_anno = nr.nr_anno
    self.nr_seq  = nr.last_seq
  end

  
  
  def pdf_link
    self.doc_file.url(:original, false) unless doc_file.nil?
  end
  
  
  def self.as_json_prop()
       return {
          :include=>{
              :customer  => {:only=>[:name]}, 
              :doc_type  => {:only=>[:code, :name]}
          },
          :methods => [:customer_id_Name, :doc_type_id_Name, :pdf_link]
        }
   end     
   
  
  
  
  
    
end
