class CreateExternalData < ActiveRecord::Migration
  def change
    create_table :external_data do |t|
      t.string        :from,     limit: 20
      t.string        :code1,    limit: 30
      t.string        :code2,    limit: 30
      t.string        :code3,    limit: 30
      t.string        :code4,    limit: 30
      t.string        :code5,    limit: 30
      
      t.boolean       :closed

      t.timestamps
    end
  end
end
