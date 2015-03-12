class CreatePorts < ActiveRecord::Migration
  def change
    create_table :ports do |t|
      t.string      :port_code,             :limit => 5
      t.string      :city,                  :limit => 50
      t.string      :country,               :limit => 50
      
      t.timestamps
      t.integer :created_user_id
      t.integer :updated_user_id      
    end
  end
end
