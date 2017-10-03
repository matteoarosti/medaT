class ShipPrepareItemWeigh < ActiveRecord::Base
  belongs_to    :ship_prepare_item
  has_one       :ship_prepare,      through: :ship_prepare_item
  
  scope :ric, -> {where("qty_ric <> ?", 0)}
  scope :not_ric, -> {where("qty <> 999999")}
  
  
  def price_range
    ShipPrepare.price_range(self.created_at)
  end
  
  def price_range_val
    self.ship_prepare.price_range_val(self.price_range)
  end
      
end
