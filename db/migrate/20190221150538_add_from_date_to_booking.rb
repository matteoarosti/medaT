class AddFromDateToBooking < ActiveRecord::Migration
  def change
    add_column   :bookings,  :beginning, :date
  end
end
