class CreateGrus < ActiveRecord::Migration
  def change
    create_table :grus do |t|
      t.string      :name,                  :limit => 50
      
      t.timestamps
      t.integer :created_user_id
      t.integer :updated_user_id      
    end
  end
end
