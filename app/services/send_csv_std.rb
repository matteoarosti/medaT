class SendCsvStd
  
  def call(shipowner, shipowner_list, fe_array, email_to, sender, receiver, sum_progressive, sum_progressive_UNH, subject_pre)
    #send_TMOV(shipowner, shipowner_list, nil, email_to, sender, receiver, sum_progressive, sum_progressive_UNH, subject_pre) if fe_array.include? 'F'   
  end

  #esamples:
  #rails runner "SendCsvStd.new.send_TMOV(12, [12], 'matteo.arosti@gmail.com', Time.zone.yesterday.at_beginning_of_day, Time.zone.yesterday.at_end_of_day)"
  

  def send_TMOV(shipowner, shipwowner_list, email_to, datetime_from, datetime_to)
    #legge tutti gli hi di una data e di una compagnia
    his = HandlingItem.where({handling_headers: {shipowner_id: shipowner} })
    his = his.joins(:handling_header)
    his = his.where({operation_type: 'MT'}) #devono essere inviati solo i movimenti terminal
    
    his = his.where("datetime_op >= ?", datetime_from)
    his = his.where("datetime_op <= ?", datetime_to)
    his = his.order("datetime_op")    
    
    content_file = prepare_file_content_TMOV(his)
    content_file = content_file.to_xls
    file_name = 'TMOV_' + Time.now.strftime("%Y%m%d%H%M%S") + ".xls"
    subject = 'export_TMOV_csv_' + Time.now.strftime("%Y%m%d%H%M%S")

    if content_file != ""
      begin
        print "\n -> Invio email a #{email_to}\n"
        mm = HandlingMailer.send_codeco_email(email_to, subject, content_file, file_name).deliver!
      rescue Exception => e
        #gestire l'errore
        print "ERRORE: #{e.message}"
      end
    end

  end #call
  
  


  def prepare_file_content_TMOV(his)
    
    ret = []#''
    print "\nInserisco riga di testata csv\n"
    ret << ['data_ora_movimento', 'tipo_movimento', 'tipo_container', 'container', 'pieno_vuoto', 'booking', 'nave', 'viaggio', 'vettore', 'autista', 'sigillo', 'peso']#.to_csv

    his.each do |row|
      
      is_import_export = row.is_import_export()
      bk = row.search_booking
      #nave/viaggio lo trovo in linea o eventualmente lo recupero dal booking
      if !row.ship.nil? || !row.voyage.to_s.empty?
       out_ship    = row.ship.name.to_s unless row.ship.nil?
       out_voyage  = row.voyage.to_s 
      else
      
       if is_import_export == 'E'
         #Export: provo a recuperare nave/viaggio da booking            
         if !bk.nil?
          out_ship   = "[#{bk.ship.name.to_s}]"
          out_voyage = "[#{bk.voyage.to_s}]"
         end
       else
          #Import: provo a recuperare nave/viaggio dal movimento di sbarco
            hi_discharge = row.search_hi_by_item_type('I_DISCHARGE')
            out_ship = "[#{hi_discharge.ship.name.to_s}]" unless hi_discharge.nil?
            out_voyage = "[#{hi_discharge.voyage.to_s}]" unless hi_discharge.nil?
       end
      end
      
      if !row.booking.nil?
       out_booking = row.booking.num_booking.to_s
      else
       out_booking = "[#{bk.num_booking.to_s}]" if !bk.nil?
      end
       
      
      out_seal_ar = []
      case is_import_export
       when "I"
         out_seal_ar << row.handling_header.seal_imp_shipowner.to_s unless row.handling_header.seal_imp_shipowner.to_s.blank?
         out_seal_ar << row.handling_header.seal_imp_others.to_s unless row.handling_header.seal_imp_others.to_s.blank?
         out_weight  = row.handling_header.weight_imp
       when "E"
         out_seal_ar << row.handling_header.seal_exp_shipowner.to_s unless row.handling_header.seal_exp_shipowner.to_s.blank?
         out_seal_ar << row.handling_header.seal_exp_others.to_s unless row.handling_header.seal_exp_others.to_s.blank?
         out_weight  = row.handling_header.weight_exp        
      end  
       
      out_seal = out_seal_ar.join('/') 
      
      ret << [
        row.datetime_op.strftime("%d/%m/%y %H:%M"),
        row.handling_item_type.to_s,
        row.handling_header.equipment.equipment_type,
        row.handling_header.container_number.to_s,
        row.container_FE.to_s,
        out_booking,
        out_ship.to_s,
        out_voyage,
        row.carrier.blank? ? '' : row.carrier.name.to_s,
        row.driver.to_s,
        out_seal,
        out_weight 
      ]#.to_csv

    end #his.each
   ret
  end #prepare_file_content





end #class
