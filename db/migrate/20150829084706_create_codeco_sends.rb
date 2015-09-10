class CreateCodecoSends < ActiveRecord::Migration
  def change
    create_table :codeco_sends do |t|
      t.belongs_to :shipowner

      t.timestamps
      t.integer :created_user_id
      t.integer :updated_user_id
    end
  end
end
