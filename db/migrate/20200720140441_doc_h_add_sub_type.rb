class DocHAddSubType < ActiveRecord::Migration
  def change
    #es: subtype STD per DRA standard,
    #    subtype MSD per DRA in cui addebito (a Archibugi) le Messe a Disposizione
    add_column   :doc_hs, :subtype, :string, limit: 3  
    
    #tutti i DRA attuali vengono impostati a STD
    DocH.update_all(subtype: 'STD')
    
  end
end
