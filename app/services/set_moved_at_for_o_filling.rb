#in fase di spunta di un "assegna vuoto" ora gestisco datetime_op e moved_at.
#Fino al 15/01/2021 non lo facevo, quindi con questa call correggo i dati
# (in datetime_op salvo la data di inserimento richiesta uscita vuoto, cioe' il passaggio al box)
# (in moved_at salvo la data di spunta del mulettista)
#Serve per avere una congruenza nelle statistiche

class SetMovedAtForOFilling
  
  def correct_date
    
    #recupero tutti gli hi di tipo O_FILLING senza moved_at,
    #che sono stati generati a fronte di una movimentazione "ASSEGNA VUOTO"
    
    items = HandlingItem.where(handling_item_type: 'O_FILLING').where(moved_at: nil)
            .joins("INNER JOIN to_do_items t ON t.generated_handling_item_id = handling_items.id")
    items.each do |hi|
      puts "#id: #{hi.id}, datetime_op: #{hi.datetime_op}, container: #{hi.handling_header.container_number}"
      tdi = ToDoItem.where(generated_handling_item_id: hi.id).last
      
      minuti = (hi.datetime_op - tdi.created_at) / 1.minutes
      
      puts " > todo created_at: #{tdi.created_at}, diff: #{minuti}"
      raise "verificare date" if minuti > 30
      
      #correggo le date
      hi.datetime_op = tdi.created_at
      hi.moved_at    = hi.datetime_op
      hi.save!
      
      sssss
    end
    
  end
  
end