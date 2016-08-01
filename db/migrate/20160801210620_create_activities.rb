class CreateActivities < ActiveRecord::Migration
  def change
    create_table :activities do |t|

      t.belongs_to :customer
      t.date       :expiration_date
      t.time       :expiration_time
      
      t.text       :notes,           :limit => 64.kilobytes
      
      t.date       :execution_date
      t.integer    :execution_user_id     #chi ha registrato l'avvenuta esecuzione
      t.datetime   :execution_at          #il momento in cui e' stata registrata l'esecuzione
      t.text       :execution_notes, :limit => 64.kilobytes
      
      t.decimal    :amount,           precision: 10, scale: 2
      
      t.boolean    :request_received      #e' stata ricevuta email "ufficiale" di richiesta lavoro
      
      t.timestamps
    end
  end
end
