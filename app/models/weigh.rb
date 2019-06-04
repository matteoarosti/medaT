class Weigh < ActiveRecord::Base
  belongs_to :terminal
  belongs_to :customer
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
    
    sql_where = []
    ar_params = {}
    if !User.current.nil? && !User.current.terminal_flt.blank?
         if User.current.terminal_flt.include?(',')
           sql_where << "terminal_id IN (#{User.current.terminal_flt})"
         else
           sql_where << "terminal_id = :terminal_id"
           ar_params[:terminal_id] =  User.current.terminal_flt
         end
    end      

    
    if !User.current.nil? && !User.current.shipowner_flt.blank?
     if User.current.shipowner_flt.include?(',')
       sql_where << "shipowner_id IN (#{User.current.shipowner_flt})"
     else
       sql_where << "shipowner_id = :shipowner_id"
       ar_params[:shipowner_id] = User.current.shipowner_flt
     end
    end
          
    if !User.current.nil? && !User.current.customer_flt.blank?
     if User.current.customer_flt.include?(',')
       sql_where << "weighs.customer_id IN (#{User.current.customer_flt})"
     else
       sql_where << "weighs.customer_id = :customer_id"
       ar_params[:customer_id] = User.current.customer_flt
     end
    end
    
    if !sql_where.empty?
      return self.where(sql_where.join(' OR '), ar_params)
    end      
      
        
    return nil
  end

  
  
  def send_mail_html_to_customer   
    if 1==1 #### !self.customer.nil && !self.customer.email_notify_weigh.blank?
      #begin
        text_email = "
<h2>Cedolino pesa</h2>
Container: #{self.container_number.to_s}.<br/>
------------<br/>"        
        LogEvent.send_mail(self, 'MAIL_WE', ['matteo.arosti@gmail.com', 'm.arosti@apracs.it'], 
                  "Invio scansione pesa container #{self.container_number}", text_email,
                  {attachments: [
                                  {file_name: self.scan_file_file_name, file_path: self.scan_file.path('original')}
                                ]})
        return true        
      #rescue => exception  
      #  logger.info exception.backtrace
      #  return false
      #end
    end   
  end
  
  
  
  def self.as_json_prop()
      return {
        :methods => [:in_garage_user_name, :estimate_user_name, :estimate_sent_user_name, :estimate_authorized_user_name, :repair_completed_user_name, :out_garage_user_name], 
        :include=>{
           :terminal  => {},
           :customer  => {}
           }
         }       
  end     
  
  
end
