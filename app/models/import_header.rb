class ImportHeader < ActiveRecord::Base

  has_many :import_items
  belongs_to :ship
  
  scope :extjs_default_scope, -> {}
  scope :not_closed, -> {where("import_status <> ?", 'CLOSE')}
  
 def self.as_json_prop()
     return {
        :methods => [:ship_id_Name, :count_by_status, :hh_type_descr, :combo_descr]
      }
 end   
 
 def combo_descr
    [self.voyage, "( #{self.hh_type_descr} )"].join('  ')
 end
 
 def hh_type_descr
   I18n.t("handling_type.#{self.handling_type}.short")
 end 
 
 
 def ship_id_Name
  self.ship.name if self.ship
 end 
 
 #conto le righe di dettaglio dividendo per stato
 def count_by_status
   #####return '' if self.import_status == 'CLOSE'
   ret = []
   self.import_items.group_by{|ii| ii.status}.each do |ii_g|
     ret << [ii_g[0].to_s.empty? ? 'ToDo' : ii_g[0].to_s, ii_g[1].count].join('=>')
   end
   return ret.join(', ')
 end

  #Aggiunge un record alla tabella
  def self.add_record(ship_id, voyage, import_type, handling_type)

    import_header = ImportHeader.new
    import_header.import_status = 'OPEN'
    import_header.ship_id = ship_id
    import_header.voyage = voyage
    import_header.import_type = import_type
    import_header.handling_type = handling_type
    import_header.save!

    return import_header.id
  end

  #Verifica se il record gia' esiste, cioe' se l'importazione è già stata fatta
  def self.check_record_exist(ship_id, voyage, import_type)
    if ImportHeader.where(:ship_id => ship_id,
                      :voyage => voyage,
                      :import_type => import_type).present?
      return true
    else
      return false
    end
  end


  #*********************************************************************************
  # ESEGUE I CONTROLLI SUL FILE DI LOAD PRIMA DI PROCEDERE PER L'IMPORTAZIONE      *
  #*********************************************************************************
  def self.check_file_l(file)
    spreadsheet = open_spreadsheet(file)
    header = spreadsheet.row(1)
    ret_string = ""
    (2..spreadsheet.last_row).each do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]
      #row1 = spreadsheet.row(i)
      logger.info row
      #Shipowner.get_id_by_name(row["LINE"])
      #Equipment.get_id_by_iso(row["TYPE"])

      #Esegue il check sul numero di container

      retval = ImportHeader.check_digit(spreadsheet.row(i)[0].to_s.sub(" ", ""))
      if retval == -501
        ret_string = ret_string + "Errore nel container numero " + spreadsheet.row(i)[0].to_s.sub(" ", "") + ". Numero container non valido." + "<br>"
      end

      #Esegue il test per verificare se il peso e' un numerico
      if spreadsheet.row(i)[1] != spreadsheet.row(i)[1].to_f
        ret_string = ret_string + "Errore nel container numero " + spreadsheet.row(i)[0].to_s.sub(" ", "") + ". Peso " + spreadsheet.row(i)[1].to_s + " non valido." + "<br>"
      end

      #Esegue il test per verificare Full o Empty
      if (spreadsheet.row(i)[2].to_s[0..0] != "F") and (spreadsheet.row(i)[2].to_s[0..0] != "E")
        ret_string = ret_string + "Errore nel container numero " + spreadsheet.row(i)[0].to_s.sub(" ", "") + ". Specificare se il container è FULL o EMPTY." + "<br>"
      end

      #Esegue il test per verificare la compagnia
      if Shipowner.get_id_by_name(spreadsheet.row(i)[3].to_s) == 0
        ret_string = ret_string + "Errore nel container numero " + spreadsheet.row(i)[0].to_s.sub(" ", "") + ". Compagnia " + spreadsheet.row(i)[3].to_s + " non valida." + "<br>"
      end

      #Esegue il test per verificare se esiste l'iso
      if is_number(spreadsheet.row(i)[4])
        val = spreadsheet.row(i)[4].to_i.to_s
      else
        val = spreadsheet.row(i)[4]
      end
      retval = IsoEquipment.get_id_by_iso(val)
      if retval == ""
        ret_string = ret_string + "Errore nel container numero " + spreadsheet.row(i)[0].to_s.sub(" ", "") + ". Iso " + spreadsheet.row(i)[4].to_s + " non valido" + "<br>"
      end

      #Esegue il test per verificare se il peso e' un numerico
      if ImportHeader.is_number(spreadsheet.row(i)[6])
        booking = spreadsheet.row(i)[6].to_i.to_s
      else
        booking = spreadsheet.row(i)[6].to_s
      end
      if ImportHeader.check_booking(booking) == -1 and booking != ""
        ret_string = ret_string + "Errore nel container numero " + spreadsheet.row(i)[0].to_s.sub(" ", "") + ". Booking " + booking + " non valido." + "<br>"
      end


    end

    return ret_string
  end


  #*********************************************************************************
  # ESEGUE I CONTROLLI SUL FILE DI DISCHARGE PRIMA DI PROCEDERE PER L'IMPORTAZIONE *
  #*********************************************************************************
  def self.check_file_d(file)
    spreadsheet = open_spreadsheet(file)
    #if spreadsheet[0..3] == 'tipo'
    #  return "Errore nel tipo di file da importare."
    #end
    header = spreadsheet.row(1)
    ret_string = ""
    (2..spreadsheet.last_row).each do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]
      #row1 = spreadsheet.row(i)
      logger.info row
      #Shipowner.get_id_by_name(row["LINE"])
      #Equipment.get_id_by_iso(row["TYPE"])

      #Esegue il check sul numero di container

      retval = ImportHeader.check_digit(spreadsheet.row(i)[0].to_s.sub(" ", ""))
      if retval == -501
        ret_string = ret_string + "Errore nel container numero " + spreadsheet.row(i)[0].to_s.sub(" ", "") + ". Numero container non valido." + "<br>"
      end

      #Esegue il test per verificare se esiste l'iso
      if is_number(spreadsheet.row(i)[1])
        val = spreadsheet.row(i)[1].to_i.to_s
      else
        val = spreadsheet.row(i)[1]
      end
      retval = IsoEquipment.get_id_by_iso(val)
      if retval == ""
        ret_string = ret_string + "Errore nel container numero " + spreadsheet.row(i)[0].to_s.sub(" ", "") + ". Iso " + spreadsheet.row(i)[1].to_s + " non valido" + "<br>"
      end

      #Esegue il test per verificare Full o Empty
      if (spreadsheet.row(i)[2].to_s[0..0] != "F") and (spreadsheet.row(i)[2].to_s[0..0] != "E")
        ret_string = ret_string + "Errore nel container numero " + spreadsheet.row(i)[0].to_s.sub(" ", "") + ". Specificare se il container è FULL o EMPTY." + "<br>"
      end

      #Esegue il test per verificare la compagnia
      if Shipowner.get_id_by_name(spreadsheet.row(i)[3].to_s) == 0
        ret_string = ret_string + "Errore nel container numero " + spreadsheet.row(i)[0].to_s.sub(" ", "") + ". Compagnia " + spreadsheet.row(i)[3].to_s + " non valida." + "<br>"
      end

      #Esegue il test per verificare se il peso e' un numerico
      if spreadsheet.row(i)[4] != spreadsheet.row(i)[4].to_f
        ret_string = ret_string + "Errore nel container numero " + spreadsheet.row(i)[0].to_s.sub(" ", "") + ". Peso " + spreadsheet.row(i)[4].to_s + " non valido." + "<br>"
      end

      #Esegue il test per verificare se la temperatura e' un numerico
      if spreadsheet.row(i)[8] != spreadsheet.row(i)[8].to_f and spreadsheet.row(i)[8].to_s != ""
        ret_string = ret_string + "Errore nel container numero " + spreadsheet.row(i)[0].to_s.sub(" ", "") + ". Temperatura " + spreadsheet.row(i)[8].to_s + " non valida." + "<br>"
      end

      #Esegue il test per verificare l'imo
      if ImportHeader.check_imo(spreadsheet.row(i)[7].to_s) == -1 and spreadsheet.row(i)[7].to_s != ""
        ret_string = ret_string + "Errore nel container numero " + spreadsheet.row(i)[0].to_s.sub(" ", "") + ". Imo " + spreadsheet.row(i)[7].to_s + " non valido." + "<br>"
      end

    end

    return ret_string
  end



  def self.is_number(object)
    true if Float(object) rescue false
  end



  def self.import_d(import_header_id, file)
    spreadsheet = open_spreadsheet(file)
    header = spreadsheet.row(1)
    (2..spreadsheet.last_row).each do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]
      #row1 = spreadsheet.row(i)
      logger.info row
      #Shipowner.get_id_by_name(row["LINE"])
      #Equipment.get_id_by_iso(row["TYPE"])
      if is_number(spreadsheet.row(i)[1])
        val = spreadsheet.row(i)[1].to_i.to_s
      else
        val = spreadsheet.row(i)[1]
      end
      ImportItem.AddRecord(import_header_id,
                           Shipowner.get_id_by_name(spreadsheet.row(i)[3].to_s),  #ShipOwner
                           spreadsheet.row(i)[0].to_s.sub(" ", ""),               #Container
                           spreadsheet.row(i)[2].to_s[0..0],                      #F/E
                           IsoEquipment.get_id_by_iso(val),                       #Equipment
                           spreadsheet.row(i)[4],                                 #weight
                           spreadsheet.row(i)[8].to_f,                            #temperature
                           spreadsheet.row(i)[7].to_s,                            #IMO
                           "")                                                    #Booking
    end
  end



  def self.import_l(import_header_id, file)
    spreadsheet = open_spreadsheet(file)
    header = spreadsheet.row(1)
    (2..spreadsheet.last_row).each do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]
      #row1 = spreadsheet.row(i)
      logger.info row
      #Shipowner.get_id_by_name(row["LINE"])
      #Equipment.get_id_by_iso(row["TYPE"])
      if is_number(spreadsheet.row(i)[4])
        val = spreadsheet.row(i)[4].to_i.to_s
      else
        val = spreadsheet.row(i)[4]
      end
      if is_number(spreadsheet.row(i)[6])
        booking = spreadsheet.row(i)[6].to_i.to_s
      else
        booking = spreadsheet.row(i)[6].to_s
      end
      ImportItem.AddRecord(import_header_id,
                           Shipowner.get_id_by_name(spreadsheet.row(i)[3].to_s),    #ShipOwner
                           spreadsheet.row(i)[0].to_s.sub(" ", ""),                 #Container
                           spreadsheet.row(i)[2].to_s[0..0],                        #F/E
                           IsoEquipment.get_id_by_iso(4),                           #Equipment
                           spreadsheet.row(i)[1],                                   #weight
                           0,                                                       #temperature
                           "",                                                      #IMO
                           booking)                                                 #Booking
    end
  end

  def self.open_spreadsheet(file)
    case File.extname(file.original_filename)
      when ".csv" then Csv.new(file.path, nil, :ignore)
      #when ".xls" then Excel.new(file.path)
      when ".xlsx" then Roo::Excelx.new(file.path, nil, :ignore)
      else return "tipo di file sconosciuto: #{file.original_filename}"
    end
  end

  def self.check_digit(container_number)
    ev = [10, 12, 13 ,14, 15,
          16, 17, 18, 19, 20,
          21, 23, 24, 25, 26,
          27, 28, 29, 30, 31,
          32, 34, 35, 36, 37, 38]

    #Verifica con le espressioni regolari se il dice container e' formato da
    #3 caratteri maiuscoli + U + 7 cifre
    if test_regexp(container_number, "^([A-Z]{3}[U][0-9]{7})$") == ""
      return -501
    end

    intTot = 0

    (0..3).each do |i|
      intAsc = (container_number[i].ord - "A".ord + 1).to_i
      intTot = intTot + ev[intAsc - 1] * (2**i)
    end

    (4..9).each do |i|
      intTot = intTot + (container_number[i].to_i)*(2**i)
    end

    intCheckCntr = intTot % 11

    if intCheckCntr == 10
      strCheckCntr = "0"
    else
      strCheckCntr = intCheckCntr.to_s
    end

    if container_number[10] == strCheckCntr
      return 0
    else
      return -502
    end

  end

  def self.check_imo(imo)
    if test_regexp(imo, "^([0-9][.][0-9]|[0-9])$") == ""
      return -1
    else
      return 0
    end
  end

  def self.check_booking(booking)
    if test_regexp(booking, "^([a-zA-Z0-9]*)$") == ""
      return -1
    else
      return 0
    end
  end

  def self.test_regexp(str1, str_regex)

    reg = Regexp.new(str_regex)

    if str1.nil?
      str1 = ''
    end

    ret_val = ''
    if str1 =~ reg then
      ret_val = str1
    end

    return ret_val
  end


def status_get_data_json
 [
  {:cod=>'OPEN', :descr=>'Open'},
  {:cod=>'CLOSE', :descr=>'Close'}
 ] 
end  
 
  
  
end