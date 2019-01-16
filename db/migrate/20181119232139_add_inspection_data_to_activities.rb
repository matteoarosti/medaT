class AddInspectionDataToActivities < ActiveRecord::Migration
  def change
    
   #Tipologia attivita' 
    create_table :activity_types do |t|

      t.string  :name,            limit: 30
      t.string  :code,            limit: 15      
      
      t.integer :created_user_id
      t.integer :updated_user_id      
      t.timestamps
    end
    
    
    #Dettagli container legati all'attivita' (es: containers per visite doganali) 
     create_table :activity_dett_containers do |t|
 
       t.belongs_to :activity
       t.string     :container_number,  :limit => 11
       
       t.string     :status, limit: 5 #OPEN|CLOSE|ANN           
       
       #info per messo a disposizione
       t.integer    :make_available_user_id       #chi ha registrato l'avvenuta messa a disposizione
       t.datetime   :make_available_at            #il momento in cui e' stata registrato ...
       t.text       :make_available_notes
       t.datetime   :make_available_email_sent_at #imposto il momento in cui ho inviato l'email (se necessario)
       
       #info esecuzione dell'attivita' sul container in questione
       t.date       :execution_date
       t.integer    :execution_user_id            #chi ha registrato l'avvenuta esecuzione
       t.datetime   :execution_at                 #il momento in cui e' stata registrata l'esecuzione
       t.text       :execution_notes
       t.datetime   :execution_email_sent_at      #imposto il momento in cui invio l'email (se necessario)       
       
       #costo complessivo riguardante il singolo container
       t.decimal    :amount,           precision: 10, scale: 2
       
       t.integer :created_user_id
       t.integer :updated_user_id      
       t.timestamps
     end
        
    
    add_reference :activities, :activity_type
    add_reference :activities, :shipowner
    add_reference :activities, :terminal
    add_column    :activities, :status, :string, limit: 5 #OPEN|CLOSE|ANN
    add_column    :activities, :booking_number, :string, limit: 10
    add_column    :activities, :quantity, :integer
    add_column    :activities, :to_be_made_available, :boolean
    
    
    #per indicare le attivita' legate (selezionabili) ad una certa tipologia di attivita'
    add_reference :activity_ops, :activity_type
    add_column    :activity_ops, :to_be_made_available, :boolean  #se l'operazione puo' richiedere la messa a disposizione

  end
end
