class CreateEquipment < ActiveRecord::Migration
  def change
    create_table :equipment do |t|
      t.string      :type,                  :limit => 4
      t.integer     :size,                  :limit => 2
      t.string      :sizetype,              :limit => 50
      t.string      :iso,                   :limit => 4
      t.timestamps
    end
  end
end
