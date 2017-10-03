class CustomerAddImports < ActiveRecord::Migration
  def change
    add_column :customers, :sp_price_A, :decimal, precision: 10, scale: 2 #Importo movim. fascia A (lunvedi ... venerdi)   
    add_column :customers, :sp_price_B, :decimal, precision: 10, scale: 2 #Importo movim. fascia B (sabato...domenica)
  end
end
