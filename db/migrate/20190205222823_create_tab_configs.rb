class CreateTabConfigs < ActiveRecord::Migration
  def change
    create_table :tab_configs do |t|
      t.string      :tab,      limit: 10
      t.string      :sez1,     limit: 10
      t.string      :sez2,     limit: 10
      t.string      :des,      limit: 100
      t.text        :notes
      
      t.timestamps
    end
  end
end
