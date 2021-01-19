#in fase di spunta di un "assegna vuoto" ora gestisco datetime_op e moved_at.
#Fino al 15/01/2021 non lo facevo, quindi con questa call correggo i dati
# (in datetime_op salvo la data di inserimento richiesta uscita vuoto, cioe' il passaggio al box)
# (in moved_at salvo la data di spunta del mulettista)
#Serve per avere una congruenza nelle statistiche

class SetMovedIn
  
  def correct_date
    
    #recupero tutti gli hi di tipo O_FILLING senza moved_at,
    #che sono stati generati a fronte di una movimentazione "ASSEGNA VUOTO"
    


    items = HandlingItem.where(operation_type: 'MT')
                        .where('to_be_moved IS NOT NULL')
                        .where('moved_at IS NOT NULL')
                        .where(moved_in: nil).order(:id)            
    items.each do |hi|


	  if (hi.handling_item_type == 'O_FILLING' && hi)
	      tdi = ToDoItem.where(generated_handling_item_id: hi.id).last
	      if tdi.nil?
			puts " <-- missing tdi"
			if  hi.moved_at.nil? || hi.moved_at == hi.datetime_op
			 puts " <-- default 10 min"
			 minuti = 10
		    else
             minuti = (hi.moved_at - hi.datetime_op) / 1.minutes
            end
		  else
	        minuti = (hi.datetime_op - tdi.created_at) / 1.minutes
			puts " > todo created_at: #{tdi.created_at}, diff: #{minuti}"	
	        #raise "verificare date" if minuti > 30
		  end
	  else
		  minuti = (hi.moved_at - hi.datetime_op) / 1.minutes          
	  end	

	  minuti = 10 if minuti < 1 || minuti > 200

	  puts "#{hi.handling_item_type}: #id: #{hi.id}, datetime_op: #{hi.datetime_op}, container: #{hi.handling_header.container_number}, minuti: #{minuti}"	      


	  #data in timezone italia, per grafici per hours...
 	  #hi.datetime_op_it = hi.datetime_op.zone
	  ActiveRecord::Base.connection.execute("UPDATE handling_items SET moved_in = #{minuti}, datetime_op_it = '#{Time.zone.at(hi.datetime_op).strftime("%Y-%m-%d %H:%M")}' WHERE id=#{hi.id}")
	  #hi.moved_in = minuti
	  #hi.save!  
      ###sssss
    end
    
  end
  
end