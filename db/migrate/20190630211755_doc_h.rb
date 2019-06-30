class DocH < ActiveRecord::Migration
  def change
    
    create_table :doc_types do |t|
      t.string      :code,     limit: 5
      t.string      :name,     limit: 50
      
      t.timestamps
      t.integer :created_user_id      
      t.integer :updated_user_id
    end
    
    
    create_table :doc_nrs do |t|
      t.belongs_to :doc_type
      t.integer  :nr_anno
      t.integer  :last_seq
            
      t.timestamps
      t.integer :created_user_id      
      t.integer :updated_user_id
    end
        
    
    create_table :doc_hs do |t|
      t.belongs_to :doc_type
      t.integer  :nr_anno
      t.integer  :nr_seq
      
      t.belongs_to :customer
      t.date     :d_reg
      t.string   :status, limit: 5      #OPEN, CLOSE, ...
      t.boolean  :draft                 #bozza
      
      t.attachment  :doc_file
      
      t.timestamps
      t.integer :created_user_id      
      t.integer :updated_user_id
    end
    
    
    add_reference :activity_dett_containers, :doc_h_notifica, references: :doc_h
    add_index :activity_dett_containers, :doc_h_notifica_id
    
  end
end
