class ShipPrepareItemWeigh < ActiveRecord::Base
  belongs_to    :ship_prepare_item
  
  scope :ric, -> {where("qty_ric <> ?", 0)}
  scope :not_ric, -> {where("qty <> 999999")}    
end
