class ActivityOp < ActiveRecord::Base
  belongs_to :activity_type
  
  scope :extjs_default_scope, -> {}
    
    
  def self.all_by_type_code(type_code)
    at = ActivityType.find_by_code(type_code)
    return at.activity_ops
  end
end
