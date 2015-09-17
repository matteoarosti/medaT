class CreateToDoItems < ActiveRecord::Migration
  def change
    create_table :to_do_items do |t|
      
      t.string      :status,                :limit => 5 #OPEN/CLOSE
      
      t.string      :to_do_type,            :limit => 15  #PRE-OPERATION, ...
      
      t.string      :num_booking,           :limit => 25
      t.belongs_to  :equipment

      #da abbinare eventualmente in base a num_booking e equipment
      t.belongs_to  :booking
      t.belongs_to  :booking_item
                  
      #eventuale indicazione del container
      t.string      :container_number,       :limit => 11

      #vari campi
      t.string      :handling_item_type,    :limit => 15 #O_FILLING            
      t.string      :handling_type,         :limit => 1  #IN or OUT
      t.string      :container_FE,          :limit => 1  #FULL or EMPTY
      t.belongs_to  :shipowner
      t.belongs_to  :ship
      t.string      :voyage,                :limit => 15
      t.belongs_to  :carrier      
      t.string      :driver,                :limit => 50
      t.string      :plate,                 :limit => 15 #targa mezzo      
      
      t.text        :notes,                 :limit => 64.kilobytes
      t.text        :notes_int,             :limit => 64.kilobytes
         
      #quale hi e' stato generato dalla prenotazione
      t.integer     :generated_handling_item_id
      
      t.timestamps            
      t.integer :created_user_id      
      t.integer :updated_user_id
    end
  end
end
