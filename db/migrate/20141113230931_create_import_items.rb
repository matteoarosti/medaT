class CreateImportItems < ActiveRecord::Migration
  def change
    create_table :import_items do |t|
      t.integer     :import_header_id,      :limit => 8
      t.integer     :shipowner_id,          :limit => 8
      t.string      :container_number,      :limit => 15
      t.string      :container_status,      :limit => 1 #F/E Full or Empty
      t.integer     :equipment_id,          :limit => 6
      t.decimal     :weight,                :precision => 15, :scale => 2
      t.decimal     :temperature,           :precision => 5, :scale => 2
      t.string      :imo,                   :limit => 4
      t.string      :status,                :limit => 10 #OK, DANNEGGIATO, ...
      t.text        :notes,                 :limit => 64.kilobytes
      t.string      :num_booking,           :limit => 25
       
      t.timestamps
      t.integer :created_user_id      
      t.integer :updated_user_id            
    end
  end
end
