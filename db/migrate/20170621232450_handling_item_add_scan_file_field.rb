class HandlingItemAddScanFileField < ActiveRecord::Migration
  def change
    add_attachment :handling_items, :scan_file
  end
end
