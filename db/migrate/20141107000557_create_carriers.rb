class CreateCarriers < ActiveRecord::Migration
  def change
    create_table :carriers do |t|
      t.string      :name,                  :limit => 50
      t.string      :address,               :limit => 50
      t.string      :zip_code,              :limit => 50
      t.string      :city,                  :limit => 50
      t.string      :country,               :limit => 50
      t.string      :email,                 :limit => 50
      
      t.timestamps
      t.integer :created_user_id
      t.integer :updated_user_id
    end
  end
end
