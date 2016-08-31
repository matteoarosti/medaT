class HandlingMailer < ActionMailer::Base
  default from: "terminal@icopsrl.net"
    
  #in fase di creazione (on in fase di effettiva movimentazione)
  #invio BOLLETTINA MOVIMENTO TERMINAL
  def hh_on_create_movim_email(hi, send_to_type)            
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
    pdf = CarrierMovimPdf.new()
    pdf.m_draw(hi)
    pdf.render_file(tmp_file_name)
    print "\nGenerato"
    
    email_error_notify = 'matteo.arosti@gmail.com'
        
    #destinatario
    
    case send_to_type
      when 'carrier'
        send_to_obj = @hi.carrier
      when 'shipper' 
        send_to_obj = @hi.shipper
      else
        send_to_obj = nil
    end
    
    if send_to_obj.nil? || send_to_obj.email_notify.to_s.empty?
      send_email_to = email_error_notify
    else
      send_email_to = send_to_obj.email_notify
    end
    
    print "\nInvio email a #{send_email_to}\n"
    #allego il file e invio
    attachments["ICOP_movimento_#{hi.id.to_s}.pdf"] = File.read(tmp_file_name)
    mail(:to => send_email_to, 
          :subject => "Notifica movimento #{hi.id.to_s}, container #{@hi.handling_header.container_number}, #{text_IO}, #{text_FE}"
        )
  end
  
  
  
  
  
  
  #in fase di creazione (on in fase di effettiva movimentazione)
  #invio BOLLETTINA VISITA DOGANALE
  def hh_on_create_inspe_email(hi, send_to_type)            
    @hi = hi   
    
    
    #genero pdf da allegare
    tmp_file_name = Tempfile.new(['to_carrier_email', '.pdf']).path
    print "\nGenero #{tmp_file_name}"    
    pdf = CarrierInspePdf.new()
    pdf.m_draw(hi)
    pdf.render_file(tmp_file_name)
    print "\nGenerato"
    
    email_error_notify = 'matteo.arosti@gmail.com'
        
    #destinatario
    
    case send_to_type
      when 'carrier'
        send_to_obj = @hi.carrier
      when 'shipper' 
        send_to_obj = @hi.shipper
      else
        send_to_obj = nil
    end
    
    if send_to_obj.nil? || send_to_obj.email_notify.to_s.empty?
      send_email_to = email_error_notify
    else
      send_email_to = send_to_obj.email_notify
    end
        
    print "\nInvio email a #{send_email_to}\n"
    #allego il file e invio
    attachments["ICOP_movimento_#{hi.id.to_s}.pdf"] = File.read(tmp_file_name)
    mail(:to => send_email_to, 
          :subject => "Notifica visita doganale #{hi.id.to_s}, container #{@hi.handling_header.container_number}"
        )
  end

  #**************************************************************
  #**************************************************************
  #INVIA MAIL PER CODECO
  #**************************************************************
  #**************************************************************
  def send_codeco_email(email_to, subject, content_file, file_name)
    attachments[file_name] = content_file
    mail(:to => email_to, :subject => subject, :body => 'sent')
  end
  
  
end
