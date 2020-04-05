class AlterActivityOpsAddExcludeIfManaged < ActiveRecord::Migration
  def change
    add_column   :activity_ops,               :exclude_if_manage_empty,          :boolean
    add_column   :activity_ops,               :exclude_if_manage_full,           :boolean
  end
end
