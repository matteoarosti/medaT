class ActivityDettContainer < ActiveRecord::Base
  belongs_to :activity
  
  scope :extjs_default_scope, -> {}     

end
