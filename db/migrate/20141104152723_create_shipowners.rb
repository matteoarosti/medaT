class CreateShipowners < ActiveRecord::Migration
  def change
    create_table :shipowners do |t|
      t.string      :name,                  :limit => 50
      t.string      :short_name,            :limit => 3
      t.string      :email,                 :limit => 50
      t.decimal     :estimate_hourly_cost_provider,   :precision => 5, :scale => 2 #da fornitore
      t.decimal     :estimate_hourly_cost_customer,   :precision => 5, :scale => 2 #a compagnia
      t.string      :email_daily,           :limit => 255
      
      t.string      :name_for_interchange,  :limit => 50  #note utilizzato nelle email di invio degli interchange
      
      t.timestamps
      t.integer :created_user_id
      t.integer :updated_user_id      
    end
  end
end
