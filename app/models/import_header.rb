class ImportHeader < ActiveRecord::Base

  has_many :import_items
  belongs_to :ship
  
  scope :extjs_default_scope, -> {}
  
 def self.as_json_prop()
     return {
        :methods => :ship_id_Name
      }
 end   
 
 def ship_id_Name
  self.ship.name if self.ship
 end 

  #Aggiunge un record alla tabella
  def self.add_record(ship_id, voyage, import_type)

    import_header = ImportHeader.new
    import_header.import_status = 'OPEN'
    import_header.ship_id = ship_id
    import_header.voyage = voyage
    import_header.import_type = import_type
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

  def self.import(import_header_id, file)
    spreadsheet = open_spreadsheet(file)
    header = spreadsheet.row(1)
    (2..spreadsheet.last_row).each do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]
      row1 = spreadsheet.row(i)
      logger.info row
      Shipowner.get_id_by_name(row["LINE"])
      Equipment.get_id_by_iso(row["TYPE"])
      ImportItem.AddRecord(import_header_id,
                           Shipowner.get_id_by_name(spreadsheet.row(i)[0].to_s),
                           spreadsheet.row(i)[3].to_s,
                           'F',
                           Equipment.get_id_by_iso(spreadsheet.row(i)[1].to_i),
                           0,
                           0,
                           "")
    end
  end

  def self.open_spreadsheet(file)
    case File.extname(file.original_filename)
      when ".csv" then Csv.new(file.path, nil, :ignore)
      #when ".xls" then Excel.new(file.path, nil, :ignore)
      when ".xlsx" then Roo::Excelx.new(file.path, nil, :ignore)
      else raise "Unknown file type: #{file.original_filename}"
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

end