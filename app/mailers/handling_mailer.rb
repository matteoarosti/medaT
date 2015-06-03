class HandlingMailer < ActionMailer::Base
  default from:  Rails.application.organization.sched_default_email
  
  
  #in fase di creazione (on in fase di effettiva movimentazione)
  #invio email a vettore (carrier)
  def hh_on_create_to_carrier_email(hi)
    @hi = hi    
    mail(:to => "matteo.arosti@gmail.com", :subject => "Notifica automatica2")
  end
end
