class CreateActivityOps < ActiveRecord::Migration
  def change
    create_table :activity_ops do |t|      
      t.string :name,     limit: 50
      t.string :code,     limit: 10
      
      t.integer :created_user_id
      t.integer :updated_user_id      
      t.timestamps
    end
  end
end
