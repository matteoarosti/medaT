class CreateImportHeaders < ActiveRecord::Migration
  def change
    create_table :import_headers do |t|
      t.integer     :ship_id,               :limit => 8
      t.string      :voyage,                :limit => 15
      t.string      :import_type,           :limit => 1 #L/D Load or Discharge
      t.string      :import_status,         :limit => 5 #OPEN/CLOSE
      t.string      :handling_type,         :limit => 5 #TMOV, ...
      
      t.timestamps
      t.integer :created_user_id
      t.integer :updated_user_id            
    end
  end
end
