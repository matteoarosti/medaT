class CreateShipPrepareOps < ActiveRecord::Migration
  def change
    create_table :ship_prepare_ops do |t|
      t.string :name,     limit: 50
      
      t.integer :created_user_id
      t.integer :updated_user_id      
      t.timestamps
    end
  end
end
