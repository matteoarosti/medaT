class CreateTabNotes < ActiveRecord::Migration
  def change
    create_table :tab_notes do |t|
      
      t.string      :note_type,             :limit => 5  #tipo di nota (come il blocco nota)
      t.string      :container_number,      :limit => 11 #se fa riferimento ad un container
            
      t.string      :rsc_type,              :limit => 5  #tipo di risorsa a cui e' abbinato (es: HH, HI, WGT, ..)
      t.belongs_to  :rsc
            
      t.string      :descr,                 limit: 200   #descrizione
      t.text        :long_descr                          #descrizione estesa
      t.attachment  :attach_file
      
      t.integer :created_user_id
      t.integer :updated_user_id   
      t.timestamps
    end
    
    add_index :tab_notes, :note_type
    add_index :tab_notes, :container_number
    add_index :tab_notes, [:rsc_type, :rsc_id]
  end
end
