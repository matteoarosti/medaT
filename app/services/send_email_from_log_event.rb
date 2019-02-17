class SendEmailFromLogEvent
  def call
    
    LogEvent.where(operation_crud: 'E').where(result_at: nil).each do |i|
      ij = (ActiveSupport::JSON.decode i.notes).with_indifferent_access
      
      
      
      begin
        HandlingMailer.send_simple(ij[:email][:to], 
                                   ij[:email][:subject], 
                                   ij[:email][:msg],
                                   ij[:email][:content_type] || 'text/plain').deliver!
        i.result_at = Time.zone.now                             
        i.save!
      rescue Exception => e
        #memorizzo l'errore
        i.result_at = Time.zone.now
        i.result_notes = e.message
        i.save!
      end
      
      
            
      
    end     
    
  end #call
end #class