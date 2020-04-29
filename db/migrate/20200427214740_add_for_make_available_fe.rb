class AddForMakeAvailableFe < ActiveRecord::Migration
  def change
    
    add_reference :shipowners, :make_available_charge_to_customer, references: :customer        #cliente (es: Archibugi) a cui fatturare la messa a disposizione
    add_index     :shipowners, :make_available_charge_to_customer_id        
    add_column    :shipowners, :make_available_charge_to_customer_with_gest_code, :string, limit: 50 #cod articolo gestionale con cui fatturare (a Archibugi) la messa a disposizione
    
    #l'attivita non la addebito al cliente (non genero DRA). Eventualmente addebiterei la sola messa a disp (ie Archibugi)
    # (in questo caso la procedura di assegnazione DRA imposta doc_h_notifica_id = 0)
    add_column    :activity_ops, :exclude_from_dra, :boolean

    add_column    :activity_ops, :charge_make_available_to_customer, :boolean #se addebito la messa a disp. al cliente
    add_column    :activity_ops, :charge_make_available_to_agency,   :boolean #se addebito la messa a disp all'agenzia (ie Archibugi)
    
    #DRA in cui ho inserito la messa a disposizione (addebitata a Archibugi)
    add_reference :activity_dett_containers, :doc_h_notifica_make_available, references: :doc_h    
    add_index     :activity_dett_containers, :doc_h_notifica_make_available_id, name: 'doc_h_make_av_id'
        
  end
end
