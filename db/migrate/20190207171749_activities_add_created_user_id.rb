class ActivitiesAddCreatedUserId < ActiveRecord::Migration
  def change
    add_column   :activities, :created_user_id, :integer
    add_column   :activities, :updated_user_id, :integer
  end
end