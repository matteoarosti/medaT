class CreateShipPrepareItems < ActiveRecord::Migration
  def change
    create_table :ship_prepare_items do |t|
      t.belongs_to  :ship_prepare
      t.string      :item_status,       limit: 5  #OPEN/CLOSE
      t.string      :item_type,         limit: 2  #LS (lista imbarco/sbarco), OP (carico/scarico merce)
      t.string      :in_out_type,       limit: 1  #IN or OUT

      
      #LS - lista imbarco/sbarco
      t.belongs_to  :import_header
      
      #OP - imbarco/sbarco merce
      t.belongs_to  :ship_prepare_op    #operazione/merce da imbarcare/sbarcare
      t.boolean     :to_weigh           #true -> richiesta pesa (es: ferro sfuso)
      t.belongs_to  :um
      t.decimal     :qty,               :precision => 15, :scale => 2 #qty merce o peso
      t.integer     :moved_by_user_id   #chi ha spuntato l'operazione
      t.datetime    :moved_at      
      

      t.text        :notes,             :limit => 64.kilobytes

      t.integer :created_user_id
      t.integer :updated_user_id      
      t.timestamps
    end
  end
end
