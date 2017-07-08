class CreateShipPrepareItemWeighs < ActiveRecord::Migration
  def change
    create_table :ship_prepare_item_weighs do |t|

      t.belongs_to  :ship_prepare_item
      
      t.decimal     :qty,                   :precision => 15, :scale => 2
      t.decimal     :qty_ric,               :precision => 15, :scale => 2   #qty ricarica (da piazzale a cliente...)
            
      t.decimal     :qty_tare,                   :precision => 15, :scale => 2   #tara
      t.decimal     :qty_gross,                   :precision => 15, :scale => 2  #peso lordo
      
      t.string      :driver,                :limit => 50
      t.string      :plate,                 :limit => 15 #targa mezzo
      
      #banchina e gru
      t.belongs_to :pier
      t.belongs_to :gru      
      
      t.integer :created_user_id
      t.integer :updated_user_id
      t.timestamps
    end
  end
end
