class CreateWeighs < ActiveRecord::Migration
  def change
    create_table :weighs do |t|
      
      t.string      :weigh_status,          :limit => 5  #OPEN|CLOSE|CANC
      t.boolean     :external,              :default => false #se TRUE -> pesata non eseguita ma solo caricato cedolino consegnato dall'autista
      
      t.belongs_to  :terminal
      t.belongs_to  :shipowner
      
      t.string      :container_number,      :limit => 11
      t.belongs_to  :handling_item
      t.belongs_to  :equipment                         #per ora non usato

      t.belongs_to  :carrier
      t.string      :driver,                :limit => 50
      t.string      :plate,                 :limit => 15  #targa mezzo
      t.string      :plate_trailer,         :limit => 15  #targa rimorchio
                  
      t.datetime    :weighed_at
      t.decimal     :weight,                :precision => 15, :scale => 2 #peso merce + container
      
      t.decimal     :weight_container,      :precision => 15, :scale => 2 #peso tara container
      t.decimal     :weight_goods,          :precision => 15, :scale => 2 #peso merce 
      
      t.attachment  :scan_file
      
      t.timestamps
    end
  end
end
