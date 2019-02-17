class AddResultToLogEvent < ActiveRecord::Migration
  def change
        
    add_column   :customers,  :email_notify_activity, :string, limit: 300
    
    add_column   :log_events, :result_notes, :text
    add_column   :log_events, :result_at, :datetime
  end
end
