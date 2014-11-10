class CreateHandlingHeaders < ActiveRecord::Migration
  def change
    create_table :handling_headers do |t|
      t.string      :container_number,      :limit => 11
      t.integer     :handling_status,       :limit => 1
      t.integer     :container_status,      :limit => 2
      t.integer     :shipowner_id,          :limit => 6
      t.integer     :shipowner_id,          :limit => 6
      t.integer     :equipment_id,          :limit => 6
      t.boolean     :over_hight
      t.boolean     :transhipment
      t.string      :notes,                 :limit => 255
      t.timestamps
    end
  end
end
