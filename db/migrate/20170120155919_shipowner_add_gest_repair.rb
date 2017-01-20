class ShipownerAddGestRepair < ActiveRecord::Migration
  def change
    add_column :shipowner, :repair_active, :boolean
  end
end
