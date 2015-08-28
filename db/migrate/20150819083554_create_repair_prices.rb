class CreateRepairPrices < ActiveRecord::Migration
  def change
    create_table :repair_prices do |t|
      t.belongs_to  :repair_processing
      t.belongs_to  :shipowner
      
      #costo per cliente
      t.decimal :customer_time,           precision: 10, scale: 2
      t.decimal :customer_material_price,  precision: 10, scale: 2
      
      #costo da fornitore
      t.decimal :provider_time,           precision: 10, scale: 2
      t.decimal :provider_material_price,  precision: 10, scale: 2
      
      t.timestamps            
      t.integer :created_user_id      
      t.integer :updated_user_id
    end
  end
end
