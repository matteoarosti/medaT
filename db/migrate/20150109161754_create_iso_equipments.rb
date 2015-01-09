class CreateIsoEquipments < ActiveRecord::Migration
  def change
    create_table :iso_equipments do |t|
      t.string      :iso,                   :limit => 4
      t.belongs_to  :equipment
      t.timestamps
    end
  end
end
