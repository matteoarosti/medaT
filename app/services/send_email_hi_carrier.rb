class SendEmailHiCarrier
  def call
    #recupero tutti gli hi di cui ancora devo inviare la email (se necessario)
    HandlingItem.where('fl_send_email_carrier IS NULL').where('carrier_id IS NOT NULL').limit(30).each do |hi|
      print "Inizio ciclo hi ##{hi.id}\n"
      begin
        mm = HandlingMailer.hh_on_create_to_carrier_email(hi).deliver!
          
        #aggiorno il flag su hi
        hi.fl_send_email_carrier = true
        hi.save!

      rescue Exception => e
        #gestire l'errore
        print "ERRORE: #{e.message}"        
      end
    end
  end #call
end #class