class CreateTerminals < ActiveRecord::Migration
  def change
    create_table :terminals do |t|

      t.string      :code,             :limit => 5
      t.string      :name,             :limit => 50 
      
      t.timestamps
      t.integer :created_user_id      
      t.integer :updated_user_id                  
    end
  end
end
