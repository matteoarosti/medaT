class SendCodeco

  def call(shipowner, shipowner_list, email_to)

    send_codeco(shipowner, shipowner_list, 'F', email_to)

    send_codeco(shipowner, shipowner_list, 'E', email_to)

  end

  def send_codeco(shipowner, shipwowner_list, container_fe, email_to)
    #legge tutti gli hi di una data e di una compagnia
    his = HandlingItem.where({handling_headers: {shipowner_id: shipowner} })
    his = his.joins(:handling_header)
    his = his.where({codeco_send: nil})
    his = his.where({container_FE: container_fe})
    his = his.where({operation_type: 'MT'}) #devono essere inviati solo i movimenti terminal
    his = his.where({ship_id: nil}) #devono essere inviati solo i movimenti terminal
    his = his.limit(10)

    cs = CodecoSend.new
    cs.save

    case shipowner
      when 3 #CMA
        content_file = prepare_file_cma(shipowner, his, cs, container_fe)
        file_name = prepare_file_name_cma(shipowner, container_fe)
        subject = prepare_subject_cma(shipowner, container_fe)
    end


    if content_file != ""

      begin
        mm = HandlingMailer.send_codeco_email(email_to, subject, content_file, file_name).deliver!
        set_codeco_sent(his, cs)
        set_codeco_send(cs)
      rescue Exception => e
        #gestire l'errore
        print "ERRORE: #{e.message}"
      end

    end

  end #call


  def prepare_file_cma(shipowner, his, cs, container_fe)

    if container_fe ==  "F"
      c_fe = '5'
    end

    if container_fe ==  "E"
      c_fe = '4'
    end

    c_sender = 'ITAOIDDOR'

    c_receiver = 'CMA'

    l_time = Time.new
    c_year = l_time.year.to_s
    c_data_prep = l_time.to_s[2..3] + l_time.to_s[5..6] + l_time.to_s[8..9]
    c_ora_prep = l_time.to_s[11..12] + l_time.to_s[14..15]

    c_codeco_send = cs.id

    c_row = 'UNB+UNOA:2+' + c_sender + '+' + c_receiver + '+' + c_data_prep + ':' + c_ora_prep + '+' + c_codeco_send.to_s + "'" + "\n"


    s_count = 0 #conteggia i container totali

    #while r = cursor.fetch_hash
    his.each do |hi|

      c_count = 1 #Conteggia le line all'interno di un container'

      #Determina il progressivo del segmnento del container all'interno del codeco
      cp = CodecoProgressive.new
      cp.save
      c_progr_item = cp.id.to_s

      c_tipomovimento = hi.handling_type #determina se è un movimento di ENTRATA o di USCITA
      c_export = hi.is_import_export()

      if c_export == "E"
        c_ie = '2' #EXPORT
      else
        c_ie = '3' #IMPORT
      end

      if hi.handling_header.weight_exp.nil?
        c_peso = ""
      else
        c_peso = hi.handling_header.weight_exp.to_s
      end
      c_tipo = hi.handling_header.equipment.equipment_type.to_s
      c_container = hi.handling_header.container_number
      c_booking = hi.handling_header.num_booking.to_s
      c_data = hi.datetime_op.to_s

      c_dataora = c_data[0..3] + c_data[5..6] + c_data[8..9] + c_data[11..12] + c_data[14..15]

      c_row = c_row + 'UNH' + '+' + c_progr_item + '+CODECO:D:95B:UN:ITG14' + "'" + "\n"
      c_count += 1
      #In base al tipo di movimento 34 è per ENTRATA e 36 è per USCITA
      if c_tipomovimento == "I" then
        c_row = c_row + 'BGM+34:::GATE IN REPORT+' + c_progr_item + "+9'" + "\n"
      end
      if c_tipomovimento == "O" then
        c_row = c_row + 'BGM+36:::GATE OUT REPORT+' + c_progr_item + "+9'" + "\n"
      end
      c_count += 1
      c_row = c_row + 'NAD+MS+' +  c_sender + "'" + "\n"
      c_count += 1
      c_row = c_row + 'EQD+CN+' + c_container + '+' + c_tipo + ':102:5++' + c_ie + '+' + c_fe + "'" + "\n"
      c_count += 1

      #Se il movimento è di EXPORT allora esiste un BOOKING
      if c_export == "E" then
        if c_booking != ''
          c_destinazione = hi.handling_header.booking.port.port_code.to_s
          if c_destinazione != ''
            c_row = c_row + 'RFF+BN:' + c_booking + "'" + "\n"
            c_count += 1
          end
        end
      end
      c_row = c_row + 'DTM+7:' + c_dataora + ':203' + "'" + "\n"
      c_count += 1
      if c_export == "E" then
        c_row = c_row + 'LOC+11+' + c_destinazione.to_s + '::6' + "'" + "\n"
        c_count += 1
      end
      c_row = c_row + 'LOC+165+ITAOI:139:6+ITAOIDDOR:TER:ZZZ' + "'" + "\n"
      c_count += 1
      if container_fe == "F"
        c_row = c_row + 'MEA+AAE+G+KGM:' + c_peso + '::6' + "'" + "\n"
        c_count += 1
      end
      c_row = c_row + 'CNT+16:1' + "'" + "\n"
      c_count += 1
      c_row = c_row + 'UNT+' + c_count.to_s + '+' + c_progr_item + "'" + "\n"

      s_count += 1
    end

    c_row = c_row + 'UNZ+' + s_count.to_s + '+' + c_codeco_send.to_s + "'" + "\n"

    if s_count > 0 then #Controlla se è stata scritta almeno una riga di codeco
      return c_row
    else
      return ""
    end

  end




  def prepare_file_name_cma(shipowner, container_fe)
    if container_fe ==  "F"
      filename = 'CODECO_FULL_' + Time.now.strftime("%Y%m%d_%H%M") + ".txt"
    end

    if container_fe ==  "E"
      filename = 'CODECO_EMPTY_' + Time.now.strftime("%Y%m%d_%H%M") + ".txt"
    end

    return filename
  end




  def prepare_subject_cma(shipowner, container_fe)
    if container_fe ==  "F"
      subject = 'ICOP CODECO FULL CONTAINERS ' + Time.now.strftime("%Y%m%d_%H%M") + ".txt"
    end

    if container_fe ==  "E"
      subject = 'ICOP CODECO EMPTY CONTAINERS ' + Time.now.strftime("%Y%m%d_%H%M") + ".txt"
    end

    return subject
  end




  def set_codeco_sent(his, cs)
    his.each do |hi|
      hi.codeco_send = cs.id
      hi.save!
    end
  end




  def set_codeco_send(cs)
    cs.shipowner_id = 3
  end


end #class
