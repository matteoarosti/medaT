class CreateIsoEquipments < ActiveRecord::Migration
  def change
    create_table :iso_equipments do |t|
      t.string      :iso,                   :limit => 4
      t.belongs_to  :equipment
      
      t.timestamps
      t.integer :created_user_id      
      t.integer :updated_user_id            
    end
  end
end
