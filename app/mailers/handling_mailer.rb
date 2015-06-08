class HandlingMailer < ActionMailer::Base
  default from: "terminal@icopsrl.net"
  
  
  #in fase di creazione (on in fase di effettiva movimentazione)
  #invio email a vettore (carrier)
  def hh_on_create_to_carrier_email(hi)            
    @hi = hi    
    
    #genero pdf da allegare
    tmp_file_name = Tempfile.new(['to_carrier_email', '.pdf']).path
    print "\nGenero #{tmp_file_name}"
    
    #Prawn::Document.generate(tmp_file_name) do |pdf|
    #  pdf.text "ciaoooo"
    #end
    pdf = CarrierMovPdf.new()
    pdf.m_draw(hi)
    pdf.render_file(tmp_file_name)
    
    #allego il file e
    attachments["ICOP_movimento_#{hi.id.to_s}.pdf"] = File.read(tmp_file_name)
    mail(:to => "matteo.arosti@gmail.com", 
          :subject => "Notifica movimento #{hi.id.to_s}"
        )
  end
end
