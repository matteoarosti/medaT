class CreateShipowners < ActiveRecord::Migration
  def change
    create_table :shipowners do |t|
      t.string      :name,                  :limit => 50
      t.string      :short_name,            :limit => 3
      t.string      :email,                 :limit => 50
      t.decimal     :estimate_hourly_cost,  :precision => 5, :scale => 2
      t.timestamps
    end
  end
end
