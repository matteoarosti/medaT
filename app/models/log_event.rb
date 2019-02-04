class LogEvent < ActiveRecord::Base
  
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
  
end
