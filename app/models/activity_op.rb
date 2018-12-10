class ActivityOp < ActiveRecord::Base
  belongs_to :activity_type
  
  scope :extjs_default_scope, -> {}
end
