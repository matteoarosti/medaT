class SendEmailFromLogEvent
  def call
    
    LogEvent.where(operation_crud: 'E').where(result_at: nil).each do |i|
      ij = (ActiveSupport::JSON.decode i.notes).with_indifferent_access
            
      HandlingMailer.send_simple(ij[:email][:to], 
                                 ij[:email][:subject], 
                                 ij[:email][:msg]).deliver!
    end     
    
  end #call
end #class