class AddCustomerToWeighs < ActiveRecord::Migration
  def change
    add_reference :weighs, :customer
    add_column    :weighs, :booking_customer, :string
    add_column    :weighs, :fl_send_email_customer, :boolean, :default => nil #true=inviato, false=errore
    add_column    :users, :customer_flt, :string
    add_column    :customers, :email, :string    
  end
end
