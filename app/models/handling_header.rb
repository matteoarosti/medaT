class HandlingHeader < ActiveRecord::Base

 belongs_to :shipowner
 belongs_to :equipment
 has_many :handling_items
   
 scope :extjs_default_scope, -> { eager_load(:shipowner, :equipment) }
 scope :container, ->(container_number) {where("container_number = ?", container_number)}

 def handling_header_status() return self.handling_status end

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
  h_type_config = get_handling_type_config(operatios_config)
  
  #in base allo stato
  case self.handling_status
   when 'NEW'    #nuovo movimento, ritorno le operazioni per il movimento iniziale
    ret = []
    
    h_type_config['movimento_iniziale'].split(',').each do |op_id_yaml|
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
   else
    return []
  end
  
  return ret 
 end
 
# Verifico la correttezza di un hi in fase di inserimento
# (in base al tipo, allo stato del hh, ....) 
################################################################ 
def validate_insert_item(hi)
################################################################
 ret = {:is_valid => true, :message => nil}
 operatios_config = load_op_config    
 h_type_config = get_handling_type_config(operatios_config)

  
  #su nuovo handling header verifico che l'op sia tra quelle dichiarate come movimento iniziale
  if self.handling_status == 'NEW'
   if !h_type_config['movimento_iniziale'].split(',').include?(hi.handling_item_type)
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
   if self.send(check_op_name) != check_op_value
    ret[:is_valid] = false
    ret[:message]  = "check non superato ( #{check_op_name} , #{check_op_value} )" 
    logger.info ret.to_yaml
    return ret   
   end
  end
 
  
 return ret
end 
 
 
 
# Sincro dell'header dopo l'inserimento di un nuovo item 
################################################################ 
def sincro_save_header(hi)
################################################################

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
   self.send("sincro_set_#{set_op_name}", set_op_value)
  end
 
 self.save!
 return true
end  




################################################################
def sincro_set_container_in_terminal(value)
################################################################
 self.container_in_terminal = value
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
  self.equipment.name if self.equipment
 end 
 
 def self.as_json_prop()
     return {
        :include=>{:shipowner => {:only=>[:name]}, :equipment => {:only=>[:type]}},
        :methods => [:shipowner_id_Name, :equipment_id_Name]
      }
 end     


end
