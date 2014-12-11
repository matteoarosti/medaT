class CreateHandlingHeaders < ActiveRecord::Migration
  def change
    create_table :handling_headers do |t|
      t.string      :container_number,       :limit => 11

      t.integer     :shipowner_id,           :limit => 6
      t.integer     :shipowner_id,           :limit => 6
      t.integer     :equipment_id,           :limit => 6
      t.boolean     :over_hight
      t.boolean     :transhipment
      t.string      :notes,                  :limit => 255
      t.timestamps
      
	  #Matteo
	  t.string     :handling_type,             :limit => 5	   #TMOV, ...
	  t.string     :container_type,        	   :limit => 5
	  t.boolean    :container_OH
	  
	  #Campi auto-alimentati su aggiunta item (per validazione movimenti, ....)
    t.string     :handling_status,           :limit => 5	  
	  t.boolean    :container_in_terminal,     :default => false
    t.string     :container_status,          :limit => 5
    t.string     :container_FE,              :limit => 1
    t.integer    :booking_id    
      
    end
  end
end
