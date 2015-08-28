class CreateRepairPositions < ActiveRecord::Migration
  def change
    create_table :repair_positions do |t|
      t.string      :description_it,             :limit => 50
      t.string      :description_en,             :limit => 50      
      
      t.timestamps            
      t.integer :created_user_id      
      t.integer :updated_user_id
    end
  end
end
