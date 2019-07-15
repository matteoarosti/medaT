class AddNotificaToActivity < ActiveRecord::Migration
  def change
    add_reference :activities, :doc_h_notifica, references: :doc_h
    add_index     :activities, :doc_h_notifica_id
  end
end
