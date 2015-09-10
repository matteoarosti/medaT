class CreateCodecoProgressives < ActiveRecord::Migration
  def change
    create_table :codeco_progressives do |t|

      t.timestamps
    end
  end
end
