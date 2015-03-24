class CreateHandlingItems < ActiveRecord::Migration
  def change
    create_table :handling_items do |t|
      t.integer     :handling_header_id,    :limit => 8
      t.datetime    :datetime_op
      t.datetime    :datetime_op_end
      t.string      :operation_type,        :limit => 2  #es: MT, VD, AF, ...
      t.string      :handling_item_type,    :limit => 15  #es: SBARCO, IMBARCO, VISITA DOGANALE, ...
      t.string      :handling_type,         :limit => 1 #IN or OUT
      t.string      :container_FE,          :limit => 1 #FULL or EMPTY
      t.integer     :ship_id,               :limit => 8
      t.string      :voyage,                :limit => 15
      t.string      :driver,                :limit => 50
      t.boolean     :export
      t.string      :seal_shipowner,        :limit => 15
      t.string      :seal_others,           :limit => 15
      t.boolean     :codeco_sent
      t.text        :notes,                 :limit => 64.kilobytes      
      t.belongs_to  :carrier
      t.belongs_to  :terminal

      #abbinamento con booking
      t.belongs_to  :booking
      t.belongs_to  :booking_item 
      
      #gestione campi lock
      t.boolean    :lock_fl
      t.string     :lock_type,                 :limit => 10    #da ispezionare, in riparazione, ...
      
      #da movimentare - coda di lavoro per mulettista (da posizionare, da portare al carico, ....)
      t.boolean    :to_be_moved
      t.integer    :moved_by_user_id
      t.datetime   :moved_at      
      
      
      t.timestamps
      t.integer :created_user_id
      t.integer :updated_user_id                   
    end
  end
end