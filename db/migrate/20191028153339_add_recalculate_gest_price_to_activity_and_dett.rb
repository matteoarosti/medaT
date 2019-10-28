class AddRecalculateGestPriceToActivityAndDett < ActiveRecord::Migration
  def change

    add_column   :activities,               :amount_setted,          :boolean
        
    add_column   :activities,               :recalculate_gest_price, :boolean         #in fase di import su gestionale deve essere ricalcolato il prezzo da listino
    add_column   :activity_dett_containers, :recalculate_gest_price, :boolean         #in fase di import su gestionale deve essere ricalcolato il prezzo da listino
    
  end
end
