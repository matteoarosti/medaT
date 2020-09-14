class ImportItemsAddMossa < ActiveRecord::Migration
  def change
    add_column   :import_items, :sp_pos, :string, limit: 10
    add_column   :import_items, :sp_mossa, :string, limit: 10
  end
end
