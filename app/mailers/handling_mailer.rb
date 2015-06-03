class HandlingMailer < ActionMailer::Base
  #default from: "matteo.arosti@gmail.com"
  
  
  #in fase di creazione (on in fase di effettiva movimentazione)
  #invio email a vettore (carrier)
  def hh_on_create_to_carrier_email(hi)
    @hi = hi    
    mail(:from => "matteo.arosti@gmail.com", :to => "matteo.arosti@gmail.com", :subject => "Notifica automatica")
  end
end
