class CreateRepairProcessings < ActiveRecord::Migration
  def change
    create_table :repair_processings do |t|
      t.belongs_to  :repair_position
      t.belongs_to  :repair_component

      t.string      :description_it,             :limit => 50
      t.string      :description_en,             :limit => 50
      
      t.string      :preparation_time_type,      :limit => 50 #ID: Impact Damage, WT: Wear Time, CL: Cleaning (le operazioni CL non vanno sommate nel preparation_time del preventivo)       

      t.timestamps            
      t.integer :created_user_id      
      t.integer :updated_user_id
    end
  end
end
