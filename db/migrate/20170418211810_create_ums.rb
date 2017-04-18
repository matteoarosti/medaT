class CreateUms < ActiveRecord::Migration
  def change
    create_table :ums do |t|

      t.string   :code,   limit: 5
      t.string   :name,   limit: 20
      
      t.timestamps
    end
  end
end
