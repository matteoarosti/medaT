class CreatePtiTypes < ActiveRecord::Migration
  def change
    create_table :pti_types do |t|

      t.string  :name,            limit: 30
      t.string  :code,            limit: 5
      
      t.integer :created_user_id
      t.integer :updated_user_id      
      t.timestamps
    end
    
    add_reference :repair_handling_items, :pti_type_requested #pti requested
    add_reference :repair_handling_items, :pti_type_confirmed #pti confirmed
  end
end
