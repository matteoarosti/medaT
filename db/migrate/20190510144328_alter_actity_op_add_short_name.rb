class AlterActityOpAddShortName < ActiveRecord::Migration
  def change
    add_column   :activity_ops,  :short_name, :string, limit: 20
  end
end
