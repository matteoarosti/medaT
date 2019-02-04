class AddConfirmedDataToActivities < ActiveRecord::Migration
  def change
    
    #data/ora e utente che ha confermato l'effettiva esecuzione della visita
    add_column   :activity_dett_containers, :confirmed_at, :datetime
    add_column   :activity_dett_containers, :confirmed_user_id, :integer
    add_column   :activity_dett_containers, :confirmed_notes, :text    
    
  end
end
