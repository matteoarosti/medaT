class RepairRfcon
  
  
  ########################################################## 
  def call_all(p = {})
  ##########################################################
    cont_hh = 0
    cont_rfcon = 0
    cont_udett  = 0
       
    
   
    HandlingHeader.where('handling_type=?', 'TMOV').where('equipment_id IN (2,5)').each do |hh|
      cont_hh += 1
      
      hh_status = 0  #0 default, 1 con 'I' 'F' trovato, 2 con RFCON, 3 con 'O' 'F' trovato
      hi_start = nil
      hi_end = nil      

      #print "\n-----------------------------------------------------------"
      #print "\nId: #{hh.id}, container: #{hh.container_number}"      
                 
      #scorro i movimenti in ordine
      hh.handling_items.order('datetime_op, id').each do |hi|

        #INGRESSO PIENO
        if hi.handling_type == 'I' && hi.container_FE == 'F'
          #print "\n(ingresso pieno con id #{hi.id})"
          if hh_status != 0
            print "\nErrore hh_status (#{hh_status})"
            return 
          end
          
          hh_status = 1
          hi_start = hi          
        end

                
        #USCITA PIENO
        if hi.handling_type == 'O' && hi.container_FE == 'F'
          #print "\n(uscita pieno con id #{hi.id})"
          if hh_status < 1
            print "\n*************Errore hh_status (#{hh_status}) in #{hh.container_number} ************"
            return unless hi.handling_item_type == 'O_LOAD'
          end
          
          
          if hh_status == 2 #con RFCON
            #print "\nRFCON gia' presente"
            #resetto stato
            hh_status = 0
            hi_start = nil
            hi_end = nil                  
          end

          if hh_status == 1 #solo ingresso PIENO
            hh_status = 1
            hi_end = hi          
            
            print "\nDevo creare RFCON per #{hh.container_number} con data #{hi_start.datetime_op.to_s} - #{hi_end.datetime_op.to_s}"
            
            if hi_start.datetime_op == hi_end.datetime_op
              print "\nDate hi_start e hi_end coincidenti. "
              return
            end

              #creo dettaglio allaccio frigo
                       hi_reefer = hh.handling_items.new()
                       hi_reefer.datetime_op = hi_start.datetime_op
                       hi_reefer.datetime_op_end = hi_end.datetime_op
                       hi_reefer.operation_type = 'AF'
                       hi_reefer.handling_item_type = 'FRCON'
                       hi_reefer.save! if p[:with_save] == 'Y'            
            
            
            #resetto stato
            hh_status = 0
            hi_start = nil
            hi_end = nil      
            
          end
                              
        end
        
        
        
        #Allaccio frigo
        if hi.handling_item_type == 'FRCON'
          #print "\nTrovato allaccio frigo"
          hh_status = 2
        end
        
        
      end #do hi
      
      
      #print "\n\n"
    end
    
    print "\n\nTotale hh: #{cont_hh}"
    print "\n\nTotale hh con rfcon: #{cont_rfcon}"
    print "\n\nTotale hh udett: #{cont_udett}"    
    
  end
  
  
  
  
  
  
  
  
  def test_datetime_op
    cont_hh = 0
    cont_rfcon = 0
    cont_udett  = 0

    #verifico dopo non e' rispettato l'ordinamento datetime_op
    HandlingHeader.where('handling_type=?', 'TMOV').each do |hh|
      last_datetime_op = nil
      error = 0
      error_datetime_op = nil
      hh.handling_items.order('id').each do |hi|
        if !last_datetime_op.nil? && hi.datetime_op < last_datetime_op
          error_datetime_op = hi.datetime_op
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
              if hi.datetime_op < '28-06-2015 00:00:00' && last_datetime_op < '28-06-2015 00:00:00'
                print "\nDa correggere hi #{hi.handling_item_type} con id #{hi.id} (datetime: #{hi.datetime_op.to_s} -> #{last_datetime_op} "
                print "\nLast datetime hh: #{hh.last_dett.datetime_op.to_s}"                
                print "\n - ESEGUO"
                hi.datetime_op = last_datetime_op
                hi.save!                
              end
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
