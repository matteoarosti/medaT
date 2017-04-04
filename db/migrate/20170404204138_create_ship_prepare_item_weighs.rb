class CreateShipPrepareItemWeighs < ActiveRecord::Migration
  def change
    create_table :ship_prepare_item_weighs do |t|

      t.belongs_to  :ship_prepare_item
      
      t.decimal     :weight,                :precision => 15, :scale => 2 #peso merce + container
      
      t.decimal     :weight_container,      :precision => 15, :scale => 2 #peso tara container
      t.decimal     :weight_goods,          :precision => 15, :scale => 2 #peso merce       
      
      t.string      :driver,                :limit => 50
      
      t.integer :created_user_id
      t.integer :updated_user_id
      t.timestamps
    end
  end
end
