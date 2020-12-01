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
    pdf = CarrierMovimPdf.new() #Interchange
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
      
    #se devo aggiungere attachments aggiuntivi da TabConfig
    add_attach = TabConfig.find_by(tab: 'INTERC', sez1: 'ATTACH_01')
    if add_attach && add_attach.attach_file_file_size.to_i > 0
      attachments[add_attach.attach_file_file_name] = File.binread(add_attach.attach_file.path('original'))
    end
    
    #se devo aggiungere BCC (da TabConfig)
    bcc_interchange = TabConfig.get_notes('INTERC', 'BCC')
    
    mail(:to => send_email_to, 
          :bcc => bcc_interchange,
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
    mail(:to => email_to, :subject => subject, :body => 'E-mail generata automaticamente')
  end
  
  

  #**************************************************************
  #**************************************************************
  #INVIA MAIL CON BODY INLNE
  #**************************************************************
  #**************************************************************
  def send_simple(email_to, subject, body, content_type = 'text/plain', ar_attachments = [])
    if !ar_attachments.nil? && ar_attachments.length > 0
      ar_attachments.each do |a|
        a = a.with_indifferent_access
        attachments[a[:file_name]] =  File.read(a[:file_path]) 
      end
      mail(:to => email_to, :subject => subject, :body => body, content_type: content_type, override_mail_fn: true)
    else
      mail(:to => email_to, :subject => subject, :body => body, content_type: content_type, override_mail_fn: false) 
    end 
  end
  
  
  
  
  #override per inviare correttamente allegati
  def mail(headers = {}, &block)
    message = super    

    # If there are no regular attachments, we don't have to modify the mail
    ###return message unless message.parts.any? { |part| part.attachment? && !part.inline? }
    return message unless headers[:override_mail_fn]  
      
    # Combine the html part and inline attachments to prevent issues with clients like iOS
    html_part = Mail::Part.new do
      content_type 'multipart/related'
      message.parts.delete_if { |part| (!part.attachment? || part.inline?) && add_part(part) }
    end

    # Any parts left must be regular attachments
    attachment_parts = message.parts.slice!(0..-1)

    # Reconfigure the message
    message.content_type 'multipart/mixed'
    message.header['content-type'].parameters[:boundary] = message.body.boundary
    message.add_part(html_part)
    attachment_parts.each { |part| message.add_part(part) }

    message
  end
  
  
end
