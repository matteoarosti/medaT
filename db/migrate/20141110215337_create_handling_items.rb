class CreateHandlingItems < ActiveRecord::Migration
  def change
    create_table :handling_items do |t|
      t.integer     :handling_header_id,    :limit => 8
      t.datetime    :date
      t.string      :handling_item_type,    :limit => 15  #es: SBARCO, IMBARCO, VISITA DOGANALE, ...
      t.string      :handling_type,         :limit => 1 #IN or OUT
      t.string      :container_FE,          :limit => 1 #FULL or EMPTY
      t.integer     :ship_id,               :limit => 8
      t.string      :voyage,                :limit => 15
      t.integer     :carrier_id,            :limit => 8
      t.string      :driver,                :limit => 50
      t.boolean     :export
      t.boolean     :not_positioning
      t.boolean     :codeco_sent
      t.string      :notes,                 :limit => 255
      t.timestamps

      #Matteo
      t.integer     :booking_id
    end
  end
end
