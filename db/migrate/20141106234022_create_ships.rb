class CreateShips < ActiveRecord::Migration
  def change
    create_table :ships do |t|
      t.string      :name,                  :limit => 50
      t.string      :short_name,             :limit => 10
      t.string      :call_sign,             :limit => 10
      ##t.integer     :shipowner_id,          :limit => 4
      t.belongs_to :shipowner
      
      t.timestamps
      t.integer :created_user_id
      t.integer :updated_user_id      
    end
  end
end
