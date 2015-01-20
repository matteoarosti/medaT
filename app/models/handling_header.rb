class HandlingHeader < ActiveRecord::Base

 belongs_to :shipowner
 belongs_to :equipment
 belongs_to :booking
 has_many :handling_items
   
 scope :extjs_default_scope, -> { eager_load(:shipowner, :equipment) }
 scope :container, ->(container_number) {where("container_number = ?", container_number)}
 scope :booking, ->(booking_number) {where("container_number = ?", container_number)}

 def handling_header_status() return self.handling_status end

  #valori per combo
  def handling_type_get_data_json
   [
    {:cod=>'TMOV', :descr=>'Movimento terminal'},
    {:cod=>'FRCON', :descr=>'Allaccio frito'},
    {:cod=>'INSPE', :descr=>'Visita doganale'}
   ]
  end
  def container_status_get_data_json
   [
    
   ]
  end
  def status_get_data_json
   [
    {:cod=>'NEW', :descr=>'New'},
    {:cod=>'OPEN', :descr=>'Open'},
    {:cod=>'CLOSE', :descr=>'Close'}
   ] 
  end 




 #Richiamata per la creazione di un nuovo header da import
 def self.create_new(rec, params)
   hh = HandlingHeader.new
   hh.container_number = rec.container_number
   hh.handling_type = "TMOV"
   hh.shipowner_id = rec.shipowner_id
   hh.equipment_id = rec.equipment_id
   hh.handling_status = "NEW"
   hh.save!
   return hh
 end

  #Richiamata per la retrieve di un header in fase di imbarco
  def self.find_exist(rec, params)
    hh = HandlingHeader.container(rec.container_number).where("handling_status = ?", "OPEN").first
    return hh
  end

 def self.as_json_prop()
     return {
        :include=>{:shipowner => {:only=>[:name]}, :equipment => {:only=>[:type]}},
        :methods => [:shipowner_id_Name, :equipment_id_Name, :booking_id_Name]
      }
 end     
 

#COSTANTI
 TYPES = {
  "TMOV" => 'Movimentazione Terminal'
 }



 #in base allo stato, al tipo e all'ultima operazione
 # ritorno le operazioni ammesse su un handling header
################################################################
 def get_operations()
################################################################
  operatios_config = load_op_config
  ret = []      
  h_type_config = get_handling_type_config(operatios_config)
  hi = self.handling_items.new()
  
  #in base allo stato
  case self.handling_status
   when 'NEW'    #nuovo movimento, ritorno le operazioni per il movimento iniziale

    h_type_config['initial_handling'].split(',').each do |op_id_yaml|
     op_id = op_id_yaml.strip
     op_config = h_type_config[op_id]     
         
     new_op = {
      :cod    => op_id,
      :label  => op_config['label'],
      :icon   => op_config['icon']
     }
     ret << new_op
    end 

   when 'OPEN'
    for op_id, op_config in h_type_config
      next if op_id == 'initial_handling'
      
      hi.handling_item_type = op_id
      op_valid = self.validate_insert_item(hi, 'get_operations')
      
      if op_valid[:is_valid] == true
         new_op = {
          :cod    => op_id,
          :label  => op_config['label'],
          :icon   => op_config['icon']
         }
         ret << new_op       
      end
       
    end #per ogni op
    return ret
   else
    return []
  end
  
  return ret 
 end
 
# Verifico la correttezza di un hi in fase di inserimento
# (in base al tipo, allo stato del hh, ....) 
################################################################ 
def validate_insert_item(hi, name_function = '')
################################################################
 ret = {:is_valid => true, :message => nil}
 operatios_config = load_op_config    
 h_type_config = get_handling_type_config(operatios_config)

  
  #su nuovo handling header verifico che l'op sia tra quelle dichiarate come movimento iniziale
  if self.handling_status == 'NEW'
   if !h_type_config['initial_handling'].split(',').include?(hi.handling_item_type)
    ret[:is_valid] = false
    ret[:message]  = 'Operazione non ammessa come iniziale'
    logger.info ret.to_yaml
    return ret
   end 
  end
  
  #verifiche sui "check" dichiarati sull'op
  op_config = h_type_config[hi.handling_item_type]
  op_config_check = op_config['check'] || {}

  for check_op_name, check_op_value in op_config_check   
    
    if check_op_value.is_a? Hash
      case check_op_value['operator']
      when "IN"
        test_is_valid = check_op_value['value'].split('|').include?(self.send(check_op_name))
      when "NOT IN"
        test_is_valid = !check_op_value['value'].split('|').include?(self.send(check_op_name))          
      else
        test_is_valid = false
      end
    else
      test_is_valid = (self.send(check_op_name) == check_op_value)
    end
      
   #if self.send(check_op_name) != check_op_value
   if !test_is_valid
    ret[:is_valid] = false
    ret[:message]  = "check non superato ( #{check_op_name} , #{check_op_value} )" 
    logger.info ret.to_yaml
    return ret   
   end
  end
 
  #se ha "booking_copy" = true verifico l'esistenza, la validita' e l'ammissibilita' del booking
  op_config_set = op_config['set'] || {}
  if name_function != 'get_operations' && op_config_set['booking_copy'] == true
   
   #segnalo errore: booking non presente
   if hi.booking.nil?
    ret[:is_valid] = false
    ret[:message]  = "Booking non presente" 
    logger.info ret.to_yaml
    return ret      
   end
   
   #segnalo errore: booking non valido (quantity o expiration...)   
   verifica_validazione = hi.booking.valida_insert_item(hi)
   if verifica_validazione[:is_valid] == false
    ret[:is_valid] = false
    ret[:message]  = verifica_validazione[:message] 
    return ret   
   end
   
  end 
  
 return ret
end 
 
 
 
# Sincro dell'header dopo l'inserimento di un nuovo item 
################################################################ 
def sincro_save_header(hi)
################################################################
 message = []
 operatios_config = load_op_config    
 h_type_config = get_handling_type_config(operatios_config)
  
  #su nuovo handling header assegno lo stato di OPEN
  if self.handling_status == 'NEW'
   self.handling_status = 'OPEN' 
  end
  
  #Elaboro le operazioni dichiarate in "set"
  op_config = h_type_config[hi.handling_item_type]
  op_config_set = op_config['set'] || {}

  for set_op_name, set_op_value in op_config_set 
   self.send("sincro_set_#{set_op_name}", set_op_value, hi)
  end
 
 #salvo handling_header
 self.save!
 
 #se e' un handling_item che gestisce il bookin, aggiorno lo stato del booking
 ret_booking = {} 
 ret_booking = hi.handling_header.booking.refresh_status if op_config_set['booking_copy'] == true
 message << ret_booking[:message] unless ret_booking[:message].blank?  
 
 return {:success => true, :message => message}
end  



################################################################
def with_booking()
################################################################
 if self.booking_id == nil
  return false
 else
  return true
 end
end


################################################################
def sincro_set_container_in_terminal(value, hi)
################################################################
 self.container_in_terminal = value
end

################################################################
def sincro_set_container_FE_copy(value, hi)
################################################################
 self.container_FE  = hi.container_FE
end

################################################################
def sincro_set_booking_copy(value, hi)
################################################################
 b = Booking.find(hi.booking_id)
 self.booking_id  = hi.booking_id
 self.num_booking = b.num_booking
end

################################################################
def sincro_set_seal_imp_copy(value, hi)
################################################################
 self.seal_imp_shipowner  = hi.seal_shipowner unless hi.seal_shipowner.blank?
 self.seal_imp_others     = hi.seal_others unless hi.seal_others.blank?
end
################################################################
def sincro_set_seal_exp_copy(value, hi)
################################################################
 self.seal_exp_shipowner  = hi.seal_shipowner unless hi.seal_shipowner.blank?
 self.seal_exp_others     = hi.seal_others unless hi.seal_others.blank?
end

################################################################
def sincro_set_with_booking(value, hi)
################################################################
end

################################################################
def sincro_set_movimento_status(value, hi)
################################################################
 self.handling_status = value
end

################################################################
def sincro_set_operation_type(value, hi)
################################################################
 hi.operation_type = value
 hi.save!
end

################################################################
def sincro_set_start_fridge_connection(value, hi)
################################################################
  #verifico che l'equipment sia di tipo freeze e se necessario genero il movimento allaccio frigo
  if self.equipment.reefer == true
    if (value == true || (value == 'IF_FULL' && hi.container_FE == 'F') || (value == 'IF_EMPTY' && hi.container_FE == 'E'))
      logger.info "Creao allaccio frigo"
      hi_reefer = self.handling_items.new()
      hi_reefer.datetime_op = hi.datetime_op
      hi_reefer.operation_type = 'AF'
      hi_reefer.handling_item_type = 'FRCON'
      hi_reefer.save!
    end
  end 
end

################################################################
def sincro_set_end_fridge_connection(value, hi)
################################################################
  #se richiesto chiudo l'operazione di allaccio frigo per il container in corso
    if (value == true)
      logger.info "Termino allaccio frigo"
      self.handling_items.each do |hi_reefer|
        if hi_reefer.handling_item_type == 'FRCON'
           hi_reefer.datetime_op_end = hi.datetime_op
           hi_reefer.save!
        end
      end
    end
end
 
 
 
################################################################
def get_handling_type_config(operatios_config)
################################################################
 operatios_config[self.handling_type.to_s]
end
 
 
 
################################################################
def load_op_config
################################################################
 YAML.load_file("config/operations_config.yml")
end
 



################################################################   
#per decodifica chiavi in extjs_scaffold
################################################################   
 def shipowner_id_Name
  self.shipowner.name if self.shipowner
 end
 def equipment_id_Name
  self.equipment.sizetype if self.equipment
 end 
 def booking_id_Name
  self.booking.num_booking if self.booking
 end 


end
