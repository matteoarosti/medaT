class CreateRepairEstimateItems < ActiveRecord::Migration
  def change
    create_table :repair_estimate_items do |t|

      t.belongs_to  :repair_handling_item #rappresenta la testata preventivo

      t.belongs_to  :repair_processing    #lavorazione

      #costo da fornitore
      t.decimal :provider_time,            precision: 10, scale: 2
      t.decimal :provider_hourly_cost,     precision: 10, scale: 2      
      t.decimal :provider_material_price,  precision: 10, scale: 2

      #costo per cliente
      t.decimal :customer_time,            precision: 10, scale: 2
      t.decimal :customer_hourly_cost,     precision: 10, scale: 2      
      t.decimal :customer_material_price,  precision: 10, scale: 2

      t.decimal :quantity,                 precision: 10, scale: 2
      
      t.boolean :confirmed                 #autorizzato si/no
      
      t.string  :preparation_time_type,    :limit => 50 #ID: Impact Damage, WT: Wear Time, CL: Cleaning (le operazioni CL non vanno sommate nel preparation_time del preventivo)
      
      t.string  :side,                     :limit => 20 #dettaglio posizione (es: lato sx, ....)
      
      t.text    :provider_notes,           :limit => 64.kilobytes
      
      t.timestamps            
      t.integer :created_user_id      
      t.integer :updated_user_id
    end
  end
end
