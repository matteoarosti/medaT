class CreateBookings < ActiveRecord::Migration
  def change
    create_table :bookings do |t|
      t.string      :num_booking,           :limit => 25
      t.integer     :shipowner_id,          :limit => 6
      t.integer     :ship_id,               :limit => 6
      t.string      :voyage,                :limit => 15
      t.integer     :port_id,               :limit => 6
      t.date        :eta
      ####t.integer     :quantity,              :limit => 6             #Totalizzare per dettaglio?
      t.string      :status,                :limit => 5             #OPEN/CLOSE (gestito anche in dettaglio)
      t.text        :notes,                 :limit => 64.kilobytes
      t.date        :expiration                                     #dat limite di utilizzo del booking (per assegnazione)
      t.boolean     :to_check,              :default => true
      
      #richiedi pesa in terminal o il camionista ha gia' la pesa
      t.boolean    :to_weigh_in_terminal,  :default => nil #true=da pesare
      
      t.timestamps
      t.integer :created_user_id
      t.integer :updated_user_id      
    end
    
    #Booking item (per equipment)
    create_table :booking_items do |t|
      t.belongs_to  :booking            
      t.belongs_to  :equipment
      t.integer     :quantity,              :limit => 6
      t.string      :status,                :limit => 5             #OPEN/CLOSE
      
      #Per frigo
      t.decimal     :temperature,           :precision => 5, :scale => 2
      
      t.decimal     :ventilation,           :precision => 5, :scale => 2
      ####t.text        :ventilation,           :limit => 7
      
      t.decimal     :humidity
      
      t.timestamps
      t.integer :created_user_id
      t.integer :updated_user_id      
    end    
    
  end
end