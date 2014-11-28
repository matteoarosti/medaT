class CreateHandlingItems < ActiveRecord::Migration
  def change
    create_table :handling_items do |t|
      t.integer     :handling_header_id,    :limit => 8
      t.datetime    :date
      t.string      :handling_item_type,    :limit => 10  #es: SBARCO, IMBARCO, VISITA DOGANALE, ...
      #t.integer     :handling_type,         :limit => 1 ??? Cosa rappresenta?
      #t.integer     :container_status,      :limit => 1 ??? Cosa rappresenta?
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
      t.string      :eu,                    :limit => 1
      t.string      :pv,                    :limit => 1
      t.integer     :booking_id
    end
  end
end
