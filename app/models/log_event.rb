class LogEvent < ActiveRecord::Base
  
  
  def self.all_for(e)
    LogEvent.where(entity_name: e.class.name, entity_id: e.id)
  end
  
  def self.base(e, op_crud = nil, op = 'ND', p = {})
    #LogEvent.base(hh, 'U', 'after_cu_inspect_conf', {from: old_valye, to: params[:check_form][:nuovo_sigillo]})
    LogEvent.create!({
      entity_name: e.class.name,
      entity_id: e.id,
      operation_crud: op_crud,
      operation: op,
      notes: p.to_json
    })
  end

  
  
  def self.send_mail(e, op = 'ND', to = nil, subject = '', msg = '', p = {})
    LogEvent.create!({
      entity_name: e.class.name,
      entity_id: e.id,
      operation_crud: 'E',
      operation: op,
      notes: {
        email: {
          to: to,
          subject: subject,
          msg: msg,
          attachments: p[:attachments] || []
        }
      }.to_json
    })
  end
  
  
  
  
  def self.send_mail_html(e, op = 'ND', to = nil, subject = '', msg = '', p = {})
    LogEvent.create!({
      entity_name: e.class.name,
      entity_id: e.id,
      operation_crud: 'E',
      operation: op,
      notes: {
        email: {
          to: to,
          subject: subject,
          msg: msg,
          content_type: 'text/html',
          attachments: p[:attachments] || []
        }
      }.to_json
    })
  end  
    
end
