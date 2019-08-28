class AddInfoForActivities < ActiveRecord::Migration
  def change
    add_column   :customers,  :address,   :text
    add_column   :customers,  :gest_code, :string,   limit: 50
    
    add_column   :activity_ops, :gest_code, :string, limit: 50
    add_column   :activity_ops, :recalculate_gest_price, :boolean         #in fase di import su gestionale deve essere ricalcolato il prezzo da listino
  end
end
