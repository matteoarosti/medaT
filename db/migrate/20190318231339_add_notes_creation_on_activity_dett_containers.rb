class AddNotesCreationOnActivityDettContainers < ActiveRecord::Migration
  def change
    add_column   :activity_dett_containers,  :creation_notes, :text
  end
end
