class CreateCustomers < ActiveRecord::Migration
  def change
    create_table :customers do |t|

      t.string      :name,  :limit => 50
      
      t.timestamps
    end
  end
end
