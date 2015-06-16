class HandlingMailer < ActionMailer::Base
  default from: "terminal@icopsrl.net"
  
  
  #in fase di creazione (on in fase di effettiva movimentazione)
  #invio email a vettore (carrier)
  def hh_on_create_to_carrier_email(hi)            
    @hi = hi   
    
    text_IO = '??'
    if (@hi.handling_type == 'O')        
      text_IO = 'OUT'
    elsif (@hi.handling_type == 'I')
      text_IO = 'IN'
    end


    text_FE = '??'
    if (@hi.container_FE == 'F')        
      text_FE = 'FULL'
    elsif (@hi.container_FE == 'E')
      text_FE = 'EMPTY'
    end     
    
    #genero pdf da allegare
    tmp_file_name = Tempfile.new(['to_carrier_email', '.pdf']).path
    print "\nGenero #{tmp_file_name}"
    
    #Prawn::Document.generate(tmp_file_name) do |pdf|
    #  pdf.text "ciaoooo"
    #end
    pdf = CarrierMovPdf.new()
    pdf.m_draw(hi)
    pdf.render_file(tmp_file_name)
    print "\nGenerato"

    
    email_error_notify = 'matteo.arosti@gmail.com'
        
    #destinatario
    if @hi.carrier.nil? || @hi.carrier.email_notify.to_s.empty?
      send_email_to = email_error_notify
    else
      send_email_to = @hi.carrier.email_notify
    end
    
    print "\nInvio email a #{send_email_to}\n"
    #allego il file e invio
    attachments["ICOP_movimento_#{hi.id.to_s}.pdf"] = File.read(tmp_file_name)
    mail(:to => send_email_to, 
          :subject => "Notifica movimento #{hi.id.to_s}, container #{@hi.handling_header.container_number}, #{text_IO}, #{text_FE}"
        )
  end
end
