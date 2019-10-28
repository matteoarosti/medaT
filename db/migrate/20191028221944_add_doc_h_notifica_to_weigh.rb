class AddDocHNotificaToWeigh < ActiveRecord::Migration
  def change
    add_reference :weighs, :doc_h_notifica, references: :doc_h
    add_index :weighs, :doc_h_notifica_id        
  end
end
