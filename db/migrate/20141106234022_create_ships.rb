class CreateShips < ActiveRecord::Migration
  def change
    create_table :ships do |t|
      t.string      :name,                  :limit => 50
      t.string      :shot_name,             :limit => 4
      t.string      :call_sign,             :limit => 4
      t.integer     :shipowner_id,          :limit => 4
      t.timestamps
    end
  end
end
