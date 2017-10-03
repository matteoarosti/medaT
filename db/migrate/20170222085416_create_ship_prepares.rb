class CreateShipPrepares < ActiveRecord::Migration
  def change
    create_table :ship_prepares do |t|
      
      t.belongs_to :customer
      t.belongs_to :ship

      t.string     :ship_prepare_status, :limit => 5
      t.date       :departure_date
      t.string     :voyage,          :limit => 15
      t.string     :load_type,       :limit => 50   #tipologia di carico (Ferro, nichel, ...) Potrebbe diventare PickList            
      
      t.text       :notes,           :limit => 64.kilobytes
      
      t.date       :execution_date
      t.integer    :execution_user_id     #chi ha registrato l'avvenuta esecuzione
      t.datetime   :execution_at          #il momento in cui e' stata registrata l'esecuzione
      t.text       :execution_notes, :limit => 64.kilobytes
      
      t.integer    :nr_container_01       #Icop
      t.integer    :nr_container_02       #IP
      t.integer    :nr_container_03       #ACT
      t.integer    :nr_container_04       #non usato
      t.integer    :nr_container_05       #non usato
      
      t.decimal    :weight,         :precision => 15, :scale => 2 #peso in quintali            
      t.decimal    :amount,          precision: 10, scale: 2
      
      t.boolean    :request_received      #e' stata ricevuta email "ufficiale" di richiesta lavoro
            
      t.belongs_to :pier                  #banchina
      
      t.decimal    :price_range_A_val,    precision: 10, scale: 2   #costo movimentazione fascia A (standard)
      t.decimal    :price_range_B_val,    precision: 10, scale: 2   #costo movimentazione fascia B (sab/dom)

      t.integer :created_user_id
      t.integer :updated_user_id
      t.timestamps
    end
  end
end
