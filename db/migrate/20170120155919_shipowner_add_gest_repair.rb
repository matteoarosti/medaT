class ShipownerAddGestRepair < ActiveRecord::Migration
  def change
    add_column :shipowners, :repair_active, :boolean
  end
end
