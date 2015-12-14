class CreateRepairHandlingItems < ActiveRecord::Migration
  def change
    create_table :repair_handling_items do |t|
      
      t.belongs_to  :handling_item
      t.string      :repair_status
      
      #container portato in officina (inizialment combacia con il momento in cui viene indicato "DAMAGE"
      t.datetime    :in_garage_at
      t.integer     :in_garage_user_id
      
      #timestamp fine redazione preventivo
      t.datetime    :estimate_at
      t.integer     :estimate_user_id
            
      #timestamp preventivo inviato a compagnia (caricato su sito web)
      t.datetime    :estimate_sent_at
      t.integer     :estimate_sent_user_id
      
      #timestamp preventivo autorizzato (da shipowner)
      t.datetime    :estimate_authorized_at
      t.integer     :estimate_authorized_user_id     

      #timestamp riparazione completato (da officina)
      t.datetime    :repair_completed_at
      t.integer     :repair_completed_user_id     

      #container riportato in terminal dall'officina
      t.datetime    :out_garage_at
      t.integer     :out_garage_user_id
      
      t.text    :in_garage_notes,           :limit => 64.kilobytes
      t.text    :estimate_notes,            :limit => 64.kilobytes
      t.text    :estimate_sent_notes,       :limit => 64.kilobytes
      t.text    :estimate_authorized_notes, :limit => 64.kilobytes
      t.text    :repair_completed_notes,    :limit => 64.kilobytes
      t.text    :out_garage_notes,          :limit => 64.kilobytes
      
      
      
      t.timestamps            
      t.integer :created_user_id      
      t.integer :updated_user_id      
    end
  end
end
