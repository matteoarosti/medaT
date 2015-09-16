class RepairEstimateItem < ActiveRecord::Base
  belongs_to :repair_handling_item
  belongs_to :repair_processing
end
