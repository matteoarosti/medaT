class ShipPrepare < ActiveRecord::Base
  
  belongs_to :customer
  belongs_to :ship
  belongs_to :pier
  has_many   :ship_prepare_items
  has_many   :ship_prepare_item_weighs, through: :ship_prepare_items
  has_many   :handling_items
  
  scope :not_closed, -> {where("ship_prepare_status NOT IN('CLOSE', 'PREP')")}
  
  scope :extjs_default_scope, -> {}
  
  #gestione permessi in base a utente
  def self.default_scope
    
    sql_where = []
    ar_params = {}
       
    if !User.current.nil? && !User.current.customer_flt.blank?
     if User.current.customer_flt.include?(',')
       sql_where << "ship_prepares.customer_id IN (#{User.current.customer_flt})"
     else
       sql_where << "ship_prepares.customer_id = :customer_id"
       ar_params[:customer_id] = User.current.customer_flt
     end
    end
    
    if !sql_where.empty?
      return self.where(sql_where.join(' OR '), ar_params)
    end      
        
    return nil
  end
  
  
  
  
  
  
  
  def self.price_range(dt)    
    # Fascia B: da sabato alle 12 a domenica alle 24 (36 ore)
    return "B" if (dt.saturday? && dt.hour >= 12) || dt.sunday?     #fascia festiva
    return "A"                                                      #fascia standard    
  end
  
  def price_range_val(price_range)
    case price_range
      when "A"
        return self.price_range_A_val.to_f
      when "B" 
        return self.price_range_B_val.to_f
      else 
        return 0
    end
  end
  
  
  def self.as_json_prop()
      return { 
        :include=>{
           :customer  => {},
           :ship  => {},
           :pier  => {}
           }
         }       
  end     
  
  
  
  #in base a quanto definito nel campo container_positions (da excel Gianma)
  #ritorno la posizione di un dato container
  def find_container_position(container_number, operation_type)
     
    #in base a operatio_type (L o D) recupero la sequenza di imbarco/sbarco
    positions = get_container_positions(operation_type)
    return nil if positions.nil?
        
    positions.each_line do |line|
       r = line.split("\t")
       return r[1].strip.to_s.rjust(6, '0') if r[0] == container_number        
    end
    
    return nil #non trovato
  end
  
  
  #in base a quanto definito nel campo container_positions (da excel Gianma)
  #ritorno il primo container con il movimento OPEN o no (a seconda se sto facendo Imbarco o Sbarco)
  # operation_type: L (Load) o D (Discharge)
  def find_first_container_to_pos(operation_type)
    
    #devo riceve la lista gia' ordinata, oppure dovro' far passare mossa/sequenza
    #Per ora mi aspetto che l'elenco sia gia' in ordine di mossa/sequenza
    
    ar_seq = []
      
    positions = get_container_positions(operation_type)
    return nil if positions.nil?
    
    positions.each_line do |line|
       r = line.split("\t")
       ar_seq << {container_number: r[0], pos: r[1], seq: r[2]}
    end
    ar_seq_sorted = ar_seq.sort_by { |k| k[:seq] }
    
    ar_seq_sorted.each do |rl|   
       container_number = rl[:container_number].strip
       executed = is_executed(container_number, operation_type)  
       return container_number if !executed       
    end    
    return nil #non trovato
  end
  
  
  def is_executed(container_number, operation_type)
    case operation_type
     when 'L' #Imbarco: ritorno true se NON ha un movimento aperto (e' gia' stato imbarcato)
       hh = HandlingHeader.container(container_number).where("handling_status = ?", "OPEN").first
       return true if hh.nil?
     when 'D' #Sbarco: ritorno true se ha un movimento aperto (e' gia' stato sbarcato)
       hh = HandlingHeader.container(container_number).where("handling_status = ?", "OPEN").first
       return true if !hh.nil?
     end #case
    return false
  end
  
  def container_info(container_number, operation_type)
    case operation_type
      when 'L' #Imbarco: ritorno info su ultimo hh del container
        ret = {}      
        hh = HandlingHeader.container(container_number).order('id desc').first
        
        if hh
          
          ret[:weight] = hh.weight_exp
          
          if hh.equipment
            ret[:equipment_type] = hh.equipment ? hh.equipment.equipment_type : ''
              
            ar_style = []
            if hh.equipment.sp_bg_color
              ar_style << "background-color: #{hh.equipment.sp_bg_color}"
            else
              ar_style << "background-color: green"
            end  
            ar_style << "color: #{hh.equipment.sp_font_color}" if hh.equipment.sp_font_color
                          
            ret[:equipment_style] = ar_style.join(';')
          end    
        end
        
        return ret
      when 'D' #Sbarco: #ToDo
        return {}
      end #case
    return {}  
  end
  
  
  
  def find_last_container_by_gru(operation_type, parameters)
    case operation_type
     when 'L' #Imbarco:
       handling_item_type = 'O_LOAD'
     when 'D' #Sbarco:
      handling_item_type = 'I_DISCHARGE'
    end #case
    HandlingItem.where(handling_item_type: handling_item_type, gru_id: parameters[:gru_id]).order("id desc").first
  end
  
  
  
  def get_container_positions(operation_type)
    case operation_type
       when 'L' #Imbarco:
         positions =  container_positions_l
       when 'D' #Sbarco:
         positions = container_positions_d
      end #case 
    positions
  end
  
  
  
  def get_baia_status(operation_type, baia, c_ship)
    
    #dalla baia recupero i suoi numeri
    baie = []
    baie_name = []
    c_ship[:bays].each do |b|
      if b[:name].include?(baia)
        baie << b
        baie_name += b[:name] 
      end
    end
    
    ret = {}
    #scorro tutte i container e per la baia ritorno lo posizione e lo stato di ogni container
    positions = get_container_positions(operation_type)
    positions.each_line do |line|
       r = line.split("\t")
       container_number = r[0].strip
       pos = r[1].strip.to_s.rjust(6, '0')
       baia = pos[0,2]
       
       #se la baia e' in una di quelle che sto mostrando
       if baie_name.include?(baia)
         ret[pos.to_s] = {
           container_number: container_number,
           executed: is_executed(container_number, operation_type),
           container_info: container_info(container_number, operation_type)
         }         
       end
    end
    return ret
  end
  
  
  
  def update_positions_in_liste()
    #L - Load (imbarco)
    positions = get_container_positions('L')
    ids_by_sp = ShipPrepareItem.select(:import_header_id).where(
                  ship_prepare_id: self.id,
                  item_type: 'LS',
                  in_out_type: 'L').pluck(:import_header_id) 
    positions.each_line do |line|
       r = line.split("\t")
       container_number = r[0].strip
       pos = r[1].strip.to_s.rjust(6, '0')
       baia = pos[0,2]
       mossa = r[2] ? r[2].strip.to_s : ''
       
       #recupero l'id del record sulla lista di imbarco (tra quelle abbinate a ship_prepare)
       import_item = ImportItem.where(container_number: container_number)
                        .where(import_header_id: ids_by_sp).first
                                      
       if import_item
         import_item.sp_pos   = pos
         import_item.sp_mossa = mossa
         import_item.save!
       end
    end
    
    
    #D - Discharge (sbarco)
    positions = get_container_positions('D')
    ids_by_sp = ShipPrepareItem.select(:import_header_id).where(
                  ship_prepare_id: self.id,
                  item_type: 'LS',
                  in_out_type: 'D').pluck(:import_header_id)
    positions.each_line do |line|
       r = line.split("\t")
       container_number = r[0].strip
       pos = r[1].strip.to_s.rjust(6, '0')
       baia = pos[0,2]
       mossa = r[2] ? r[2].strip.to_s : ''
       
       #recupero l'id del record sulla lista di imbarco (tra quelle abbinate a ship_prepare)
       import_item = ImportItem.where(container_number: container_number)
                        .where(import_header_id: ids_by_sp).first
                                      
       if import_item
         import_item.sp_pos   = pos
         import_item.sp_mossa = mossa
         import_item.save!
       end
    end
    
      
  end
  
  
  
  
  
  
  
  
#valori per combo
def status_get_data_json
 [
  {:cod=>'OPEN',     :descr=>'Aperto'},
  {:cod=>'CLOSE',    :descr=>'Chiuso'},
  {:cod=>'PREP',     :descr=>'In preparazione'},
  {:cod=>'RIC',      :descr=>'In ricarica'}
 ]
end 
  

end
