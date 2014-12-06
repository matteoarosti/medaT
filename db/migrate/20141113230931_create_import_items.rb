class CreateImportItems < ActiveRecord::Migration
  def change
    create_table :import_items do |t|
      t.integer     :import_header_id,      :limit => 8
      t.integer     :shipowner_id,          :limit => 8
      t.string      :container_number,      :limit => 15
      t.string      :container_status,      :limit => 1 #F/E Full or Empty
      t.integer     :equipment_id,          :limit => 6
      t.decimal     :weight,                :precision => 5, :scale => 2
      t.decimal     :temperature,           :precision => 5, :scale => 2
      t.string      :imo,                   :limit => 4
      t.string      :status,                :limit => 5 #OK, DANNEGGIATO, ...
      t.text        :note,                  :limit => 64.kilobytes 
      t.timestamps
    end
  end
end
