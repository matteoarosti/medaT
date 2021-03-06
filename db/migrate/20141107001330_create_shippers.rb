class CreateShippers < ActiveRecord::Migration
  def change
    create_table :shippers do |t|
      t.string      :name,                  :limit => 50
      t.string      :address,               :limit => 50
      t.string      :zip_code,              :limit => 50
      t.string      :city,                  :limit => 50
      t.string      :country,               :limit => 50
      t.string      :email,                 :limit => 50
      t.string      :email_notify,          :limit => 200  #valori separati da ","      
      t.decimal     :unit_cost,             :precision => 5, :scale => 2
      t.decimal     :scartaggio_cost,       :precision => 5, :scale => 2
      
      t.timestamps
      t.integer :created_user_id
      t.integer :updated_user_id      
    end
  end
end
