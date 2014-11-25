class HandlingHeader < ActiveRecord::Base

 belongs_to :shipowner
 belongs_to :equipment
 has_many :handling_items
   
 scope :extjs_default_scope, -> { eager_load(:shipowner, :equipment) }
 scope :container, ->(container_number) {where("container_number = ?", container_number)}


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
