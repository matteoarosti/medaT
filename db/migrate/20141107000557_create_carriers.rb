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
    end
  end
end
