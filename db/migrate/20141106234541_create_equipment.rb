class CreateEquipment < ActiveRecord::Migration
  def change
    create_table :equipment do |t|
      t.string      :equipment_type,        :limit => 4
      t.integer     :size,                  :limit => 2
      t.string      :sizetype,              :limit => 50
      t.string      :iso,                   :limit => 4
      t.boolean     :reefer,   :default => false
      t.timestamps
    end
  end
end
