class RepairRfcon
  
  def test_datetime_op
    cont_hh = 0
    cont_rfcon = 0
    cont_udett  = 0

    #verifico dopo non e' rispettato l'ordinamento datetime_op
    HandlingHeader.where('handling_type=?', 'TMOV').each do |hh|
      last_datetime_op = nil
      error = 0
      hh.handling_items.order('id').each do |hi|
        if !last_datetime_op.nil? && hi.datetime_op < last_datetime_op
          error += 1
        else
          last_datetime_op = hi.datetime_op
        end
      end

      if error > 0
        cont_hh +=1
        print "\n(#{cont_hh}) num_errori: #{error}, Id: #{hh.id}, container: #{hh.container_number}"
        
        if error==1
          last_datetime_op = nil          
          #provo a correggere l'errore
          hh.handling_items.order('id').each do |hi|
            if !last_datetime_op.nil? && hi.datetime_op < last_datetime_op
              print "\nDa correggere hi #{hi.handling_item_type} con id #{hi.id} (datetime: #{hi.datetime_op.to_s} -> #{last_datetime_op} "
              #hi.datetime_op = last_datetime_op
              #hi.save!
            else
              last_datetime_op = hi.datetime_op
            end
          end          
        end
        
      end
      
    end #hh
    
    #per ora mi fermo qui
    return true    
  end
  
  
  ###############################################################
  def call    
  ###############################################################    
    cont_hh = 0
    cont_rfcon = 0
    cont_udett  = 0
            
    HandlingHeader.not_closed.where('handling_type=?', 'TMOV').where('equipment_id IN (2,5)').each do |hh|
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
 
 #           hi_reefer = hh.handling_items.new()
 #           hi_reefer.datetime_op = hi.datetime_op
 #           hi_reefer.operation_type = 'AF'
 #           hi_reefer.handling_item_type = 'FRCON'
 #           hi_reefer.save!            
          
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
