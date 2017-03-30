class CreateShipPrepareOps < ActiveRecord::Migration
  def change
    create_table :ship_prepare_ops do |t|
      t.string :name,     limit: 50
      t.timestamps
    end
  end
end
