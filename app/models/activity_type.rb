class ActivityType < ActiveRecord::Base
  has_many :activity_ops
  scope :extjs_default_scope, -> {}
end
