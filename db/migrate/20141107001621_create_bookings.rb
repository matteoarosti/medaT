class CreateBookings < ActiveRecord::Migration
  def change
    create_table :bookings do |t|
      t.string      :num_booking,           :limit => 25
      t.integer     :shipowner_id,          :limit => 6
      t.integer     :equipment_id,          :limit => 6
      t.integer     :ship_id,               :limit => 6
      t.string      :voyage,                :limit => 15
      t.integer     :port_id,               :limit => 6
      t.date        :eta
      t.integer     :quantity,              :limit => 6
      t.string      :status,                :limit => 5             #OPEN/CLOSE
      t.text        :notes,                 :limit => 64.kilobytes
      t.timestamps
    end
  end
end