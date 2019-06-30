class DocH < ActiveRecord::Base
  
  belongs_to :customer
  belongs_to :doc_type  
  
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
  
end
