class AlterCustomersAddEmailWeigh < ActiveRecord::Migration
  def change
    add_column   :customers,  :email_notify_weigh, :string, limit: 300
  end
end
