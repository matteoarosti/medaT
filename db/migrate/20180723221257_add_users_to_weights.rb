class AddUsersToWeights < ActiveRecord::Migration
  def change
    add_column    :weighs, :created_user_id, :integer
    add_column    :weighs, :updated_user_id, :integer
  end
end
