class AddCreatedHabdlingHeaderOnImportItems < ActiveRecord::Migration
  def change
    add_reference :import_items, :created_handling_header
  end
end
