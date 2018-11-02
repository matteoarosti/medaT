class AddPriceToActivityOp < ActiveRecord::Migration
  def change    
    add_column :activity_ops, :default_price, :decimal, precision: 10, scale: 2 
  end
end
