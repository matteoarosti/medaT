class SendEmailFromLogEvent
  def call
    
    LogEvent.where(operation_crud: 'E').where(result_at: nil).each do |i|
      ij = (ActiveSupport::JSON.decode i.notes).with_indifferent_access
            
      ret = HandlingMailer.send_simple(ij[:email][:to], 
                                 ij[:email][:subject], 
                                 ij[:email][:msg],
                                 ij[:email][:content_type] || 'text/plain').deliver!
      puts ret.to_json
    end     
    
  end #call
end #class