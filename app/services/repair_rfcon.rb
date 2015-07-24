class RepairRfcon
  def call
    
    cont_hh = 0
    cont_rfcon = 0
    cont_udett  = 0
    
    HandlingHeader.not_closed.where('handling_type=?', 'TMOV').where('equipment_id IN (2,5)').limit(100).each do |hh|
      cont_hh += 1
      
      #print "\n----------------------------\n"     
      #print "\nId: #{hh.id}, container: #{hh.container_number}"
     
      #verifico se ha ingressi PIENO
      hh.handling_items.order('datetime_op desc, id desc').each do |hi|
        if hi.handling_type == 'I' && hi.container_FE == 'F' && hi.handling_item_type != 'I_DISCHARGE'
          #print "\n(ingresso pieno con id #{hi.id}) - NO I_DISCHARGE"
          cont_rfcon +=1
          
          if hi.id == hh.last_dett.id
            cont_udett += 1            
            print "\n - ultimo dett -> creo movimento allaccio frigo "
 
            hi_reefer = hh.handling_items.new()
            hi_reefer.datetime_op = hi.datetime_op
            hi_reefer.operation_type = 'AF'
            hi_reefer.handling_item_type = 'FRCON'
            hi_reefer.save!            
          
          else
            
            if hh.last_dett.handling_item_type != 'FRCON'

             print "\n----------------------------\n"     
             print "\nId: #{hh.id}, container: #{hh.container_number}"                           
             print "\nVerificareeeeeeee"
            end
                
          end
          
        end
      end
      
      
      #print "\n\n"
    end
    
    print "\n\nTotale hh: #{cont_hh}"
    print "\n\nTotale hh con rfcon: #{cont_rfcon}"
    print "\n\nTotale hh udett: #{cont_udett}"    
  end #call
end #class
