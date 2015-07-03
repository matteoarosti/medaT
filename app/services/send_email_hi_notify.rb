class SendEmailHiNotify
  def call
    
    #email CARRIER (Vettori)
    HandlingItem.where('fl_send_email_carrier IS NULL').where('carrier_id IS NOT NULL').limit(30).each do |hi|
      print "\n(Carrier) Inizio ciclo hi ##{hi.id}"
      begin

        case hi.operation_type
          when "MT" #movimentazioni terminal
            mm = HandlingMailer.hh_on_create_movim_email(hi, 'carrier').deliver!
          when "CI" #visite doganali
            mm = HandlingMailer.hh_on_create_inspe_email(hi, 'carrier').deliver!
          else #errore?  
            mm = HandlingMailer.hh_on_create_movim_email(hi, 'error').deliver!
        end
          
        #aggiorno il flag su hi
        hi.fl_send_email_carrier = true
        hi.save!

      rescue Exception => e
        #gestire l'errore
        print "ERRORE: #{e.message}"        
      end
    end

    
    #email SHIPPER (Spedizionieri per Visite Doganali)
    HandlingItem.where('fl_send_email_shipper IS NULL').where('shipper_id IS NOT NULL').limit(30).each do |hi|
      print "\n(Shipper) Inizio ciclo hi ##{hi.id}"
      begin

        case hi.operation_type
          when "MT" #movimentazioni terminal
            mm = HandlingMailer.hh_on_create_movim_email(hi, 'shipper').deliver!
          when "CI" #visite doganali
            mm = HandlingMailer.hh_on_create_inspe_email(hi, 'shipper').deliver!
          else #errore?  
            mm = HandlingMailer.hh_on_create_movim_email(hi, 'error').deliver!
        end

          
        #aggiorno il flag su hi
        hi.fl_send_email_shipper = true
        hi.save!

      rescue Exception => e
        #gestire l'errore
        print "ERRORE: #{e.message}"        
      end
    end

    
    
  end #call
end #class