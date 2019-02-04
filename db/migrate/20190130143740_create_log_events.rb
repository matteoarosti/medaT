class CreateLogEvents < ActiveRecord::Migration
  def change
    create_table :log_events do |t|
      
      t.string    :entity_name, limit: 50
      t.integer   :entity_id
      t.string    :operation_crud, limit: 1 #C = Create, R = Read, U = Update, D = Delete
      t.string    :operation, limit: 50
       
      t.string    :code1, limit: 30 #per eventuali classificazioni e raggruppamenti
      t.string    :code2, limit: 30
      t.string    :code3, limit: 30
      
      t.text      :notes

      t.integer :created_user_id
      t.integer :updated_user_id      
      t.timestamps
    end
  end
end
