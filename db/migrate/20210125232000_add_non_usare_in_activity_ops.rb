class AddNonUsareInActivityOps < ActiveRecord::Migration
  def change
    add_column   :activity_ops, :non_usare, :boolean, default: false
  end
end
