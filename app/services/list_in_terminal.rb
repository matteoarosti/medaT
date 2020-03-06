class ListInTerminal
 
  def call(at = Time.zone.now)
    operations_config = HandlingHeader.new.load_op_config
    @oc = operations_config['TMOV']
    
    puts "Elaboro container in terminal, alla data #{at}"
    
    #Recupero tutti i movimenti aperti prima di <data>
    #Parto da tutti i movimenti aperti, oppure chiusi ma con una data di modifica maggiore di <data>
    items = HandlingHeader.by_type('TMOV')                          
                          .where("handling_status = 'OPEN' or (handling_status = 'CLOSE' and updated_at < ?)", at)
                          
    ar = []
    items.each do |hh|
      puts "--------------------------------------------------------------"
      puts hh.container_number
      puts "--------------------------------------------------------------"
      
      hh_status = calculate_hh(hh, at)
      ar << hh_status if hh_status && hh_status[:in_terminal] == true      
    end #items.each
    
    file = File.open("tmp/list_container_in_terminal.csv", "w")
    file.write(['Container', 'Compagnia', 'Equipment', 'In terimnal', 'F/E', 'Prima operazione', 'Data prima op', 'Ultima op', 'Data ultima op'].join(';') + "\n")
    ar.each do |a|
      file.write(a.values.join(';') + "\n")  
    end
    file.close
    
    #puts ar.to_yaml
    
  end #call
  
  
  def calculate_hh(hh, at)
    
    his = hh.handling_items.order('datetime_op, id').where("datetime_op < ?", at).all
    
    hh_status = {
      container: hh.container_number,
      shipowner: hh.shipowner.name,
      container_type: hh.equipment.equipment_type,
      in_terminal: false,
      container_FE: nil,
      first_op:    his[0].handling_item_type,
      first_op_at: his[0].datetime_op
    }        
    
    if his[0].datetime_op > at
      #puts "iniziato dopo data limite"
      return false
    else        
      his.each do |hi|
        puts " > #{hi.handling_item_type} - #{hi.datetime_op}"
        hh_status = update_status(hh_status, hi)
        puts hh_status.to_yaml
      end                      
    end
    hh_status
  end #calculate_hi
  
  
  def update_status(hh_status, hi)
    if !@oc[hi.handling_item_type].nil?
      oc = @oc[hi.handling_item_type]['set'] || {}
    else
      oc = {}
    end
        
    if !oc['container_in_terminal'].nil?
      hh_status[:in_terminal] = oc['container_in_terminal']
    end
    if !oc['container_FE_copy']  == true
      hh_status[:container_FE] = hi.container_FE
    end
    hh_status[:last_op] = hi.handling_item_type
    hh_status[:last_op_at] = hi.datetime_op
    hh_status
  end
    
end