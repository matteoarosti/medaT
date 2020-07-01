class AddNaveToShipPrepare < ActiveRecord::Migration
  def change
    add_column   :ship_prepares, :container_positions, :text  
  end
end
