class ShipPrepareChangeColumnNames < ActiveRecord::Migration
  def change
    rename_column :ship_prepares, :container_positions, :container_positions_l  #Imbarco
    add_column    :ship_prepares, :container_positions_d, :text                 #Sbarco  
  end
end
