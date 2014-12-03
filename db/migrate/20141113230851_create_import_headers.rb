class CreateImportHeaders < ActiveRecord::Migration
  def change
    create_table :import_headers do |t|
      t.integer     :ship_id,               :limit => 8
      t.string      :voyage,                :limit => 15
      t.string      :import_type,           :limit => 1 #L/D Load or Discharge
      t.timestamps
    end
  end
end
