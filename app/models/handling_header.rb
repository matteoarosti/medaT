class HandlingHeader < ActiveRecord::Base

 belongs_to :shipowner
 belongs_to :equipment
 belongs_to :booking
 belongs_to :pier #banchina
 has_many :handling_items, :dependent => :destroy
   
 scope :extjs_default_scope, -> { eager_load(:shipowner, :equipment) }
 scope :container, ->(container_number) {where("container_number = ?", container_number)}
 scope :is_in_terminal, -> {where("container_in_terminal=?", true)}
 scope :not_closed, -> {where("handling_status <> ?", 'CLOSE')}
 scope :locked, -> {where("handling_headers.lock_fl=?", true)}
 scope :locked_INSPECT, -> {locked.where("handling_headers.lock_type = ?", 'INSPECT')} 
 scope :locked_DAMAGED, -> {locked.where("handling_headers.lock_type IN(?)", ['DAMAGED', 'DAMAGED_AU'])}
 scope :da_posizionare, -> {where("da_posizionare = ?", true)}
 scope :by_type, ->(handling_type) {where("handling_type = ?", handling_type)}

 
 #gestione permessi in base a utente
 def self.default_scope
   if !User.current.nil? && !User.current.shipowner_flt.blank?
    if User.current.shipowner_flt.include?(',')
      return self.where("handling_headers.shipowner_id IN (#{User.current.shipowner_flt})")
    else
      return self.where("handling_headers.shipowner_id = ?", User.current.shipowner_flt)
    end
   end
   return nil
 end
 
 
 def handling_header_status() return self.handling_status end

  #valori per combo
  def handling_type_get_data_json
   [
    {:cod=>'TMOV',  :descr=>I18n.t("handling_type.TMOV.short")},
    {:cod=>'FRCON', :descr=>I18n.t("handling_type.FRCON.short")},
    {:cod=>'INSPE', :descr=>I18n.t("handling_type.INSPE.short")},
    {:cod=>'OLOAD', :descr=>I18n.t("handling_type.OLOAD.short")}
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
  def self.verify_can_create_new(container_number)
    #verifico che non ci sia gia' un movimento aperto (non in CLOSE)
    hh_count = HandlingHeader.container(container_number).where("handling_status <> ?", "CLOSE").count
    return false if hh_count > 0
  end
  


 #Richiamata per la creazione di un nuovo header da import
 def self.create_new(rec, params, only_prepare = false)
   
   #verifico che non ci sia gia' un movimento aperto (non in CLOSE)
   hh_count = HandlingHeader.container(rec.container_number).where("handling_status <> ?", "CLOSE").count
   return false if hh_count > 0
   
   hh = HandlingHeader.new
   hh.container_number = rec.container_number
   hh.handling_type = rec.import_header.handling_type || "TMOV"
   hh.shipowner_id = rec.shipowner_id
   hh.equipment_id = rec.equipment_id
   hh.handling_status = "NEW"
   hh.save! unless only_prepare == true
   return hh
 end

  #Richiamata per la retrieve di un header in fase di imbarco
  def self.find_exist(rec, params)
    hh = HandlingHeader.container(rec.container_number).where("handling_status = ?", "OPEN").first
    return false if hh.nil?
    return hh
  end

 def self.as_json_prop()
     return {
        :include=>{
            :shipowner  => {:only=>[:name]}, 
            :equipment  => {:only=>[:type]},
            :booking    => {:only=>[:voyage], :include => {:ship => {:only=>[:name]}}}
        },
        :methods => [:shipowner_id_Name, :equipment_id_Name, :booking_id_Name]
      }
 end     
 

 def get_notes_all
    ret = []
    self.handling_items.each do |hi|
      ret << {:op => hi.handling_item_type, :op_out => I18n.t("operations.#{hi.handling_item_type}.short"),
              :notes => hi.notes, :notes_int => hi.notes_int} if !hi.notes.blank? || !hi.notes_int.blank?
    end
    ret
 end

 def last_dett
  hh = self.handling_items.order('datetime_op desc, id desc').first
 end 
  
 def last_IN
  hh = self.handling_items.where("handling_type = ?", "I").order('datetime_op desc, id desc').first
 end 

 def last_OUT
  hh = self.handling_items.where("handling_type = ?", "O").order('datetime_op desc, id desc').first
 end 

 def get_I_DISCHARGE
  hh = self.handling_items.where("handling_item_type = ?", "I_DISCHARGE").first
 end 
  
 def get_O_LOAD
  hh = self.handling_items.where("handling_item_type = ?", "O_LOAD").first
 end
 
 def last_dett_by_item_type(handling_item_type)
  hh = self.handling_items.where("handling_item_type = ?", handling_item_type).order('datetime_op desc, id desc').first
 end 

def last_dett_by_lock_type(lock_type)
 hh = self.handling_items.where("lock_type = ?", lock_type).order('datetime_op desc, id desc').first
end 
 

#COSTANTI (DA NON USARE PIU')
 TYPES = {
  "TMOV" => 'Movimentazione Terminal'
 }

 
 
 #verifico l'eliminazione di una riga di dettaglio
 def hitem_delete_preview(hi)
   last_dett = self.last_dett()
   success = true
   data = []
   if last_dett.id != hi.id
     success = false
     data << {:field => "Errore.<br/>E' possibile eliminare solo l'ultimo dettaglio del movimento"}
     return {:success => success, :data => data}     
   end
   
   #se ho gia' inviato il codeco non posso eliminare il dettaglio
   if hi.codeco_send.to_i > 0
     success = false
     data << {:field => "Impossibile rimuovere.<br/>Codeo gia' inviato."}
     return {:success => success, :data => data}          
   end
   
   his = self.handling_items.where("id < ?", hi.id).order('datetime_op desc, id desc')   
   
   
   #nuovo stato
   new_status = nil
   case self.handling_status
    when "CLOSE"
      new_status = "OPEN"
    when "OPEN"
     if self.handling_items.count == 1
      new_status = "NEW"
       data << {:field => "container_FE", :old_value => self.container_FE, :new_value => nil} 
       data << {:field => "container_in_terminal", :old_value => self.container_in_terminal, :new_value => nil}
       data << {:field => "lock_type", :old_value => self.lock_type, :new_value => nil}
       data << {:field => "lock_fl",   :old_value => self.lock_fl,   :new_value => nil}         
     end  
   end
   data << {:field => "handling_status", :old_value => self.handling_status, :new_value => new_status} if !new_status.nil?
   
   #nuovo F/E
   new_FE = nil
   if !hi.container_FE.to_s.empty?
     #cerco il precedente FE impostato
     his.each do |hi_tmp|
       if !hi_tmp.container_FE.to_s.empty?
         new_FE = hi_tmp.container_FE
         break
       end
     end     
   end
   data << {:field => "container_FE", :old_value => self.container_FE, :new_value => new_FE} if !new_FE.nil? && new_FE != self.container_FE

     #nuovo container_in_terminal
     new_IO = nil
     if !hi.handling_type.to_s.empty?
       #cerco il precedente IO impostato
       his.each do |hi_tmp|
         if !hi_tmp.handling_type.to_s.empty?
           if hi_tmp.handling_type == "I"
             new_IO = true
           else
             new_IO = false
           end
           break
         end
       end     
     end
     data << {:field => "container_in_terminal", :old_value => self.container_in_terminal, :new_value => new_IO} if !new_IO.nil? && new_IO != self.container_in_terminal
     
     #reset booking
     new_booking = nil
     if !hi.booking.nil?
      data << {:field => "num_booking", :old_value => self.num_booking, :new_value => nil} if !hi.booking.nil?
     end
    
     #lock
     if hi.handling_item_type == 'INSPECT'
       data << {:field => "lock_type", :old_value => self.lock_type, :new_value => 'INSPECT'}
       data << {:field => "lock_fl",   :old_value => self.lock_fl,   :new_value => true}
     end
     if hi.handling_item_type == 'REPAIR'
       data << {:field => "lock_type", :old_value => self.lock_type, :new_value => 'DAMAGED'}
       data << {:field => "lock_fl",   :old_value => self.lock_fl,   :new_value => true}         
     end
        
   return {:success => success, :data => data}
   
 end
 
 


 #in base allo stato, al tipo e all'ultima operazione
 # ritorno le operazioni ammesse su un handling header
################################################################
 def get_operations(view_type = '')
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
      next if view_type == 'FOR_SELECT' && op_config['hide_for_select'] == 'Y'
      
      
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
    return ret
   end
  end
  
  #verifico che datatime_op sia maggiore o uguale all'ultimo movimento
  if name_function != 'get_operations' && self.handling_status != 'NEW'    
    last_datetime_op =  self.handling_items.order("datetime_op desc").first.datetime_op
    if hi.datetime_op < last_datetime_op
      ret[:is_valid] = false
      ret[:message]  = "La data/ora dell'operazione non puo' essere precedente a quella dell'ultima operazione inserita per il movimento"
      return ret
    end    
  end
  
  
  #verifiche sui "check" dichiarati sull'op
  op_config = h_type_config[hi.handling_item_type]
  op_config_check = op_config['check'] || {}

  #verifica che non sia in 'lock', a meno che non abbia impostato 'lock_type'
  if op_config_check['lock_type'].nil?
    if self.lock_fl == true
      ret[:is_valid] = false
      ret[:message]  = "check non superato ( lock )" 
      return ret      
    end
  end
      
    
   if self.handling_status != 'NEW' #se sono in NEW non eseguo i controlli di check, ma solo l'eventuale validita del booking  
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
      return ret   
     end
    end
   end 
 
  #se ha "booking_copy" = true verifico l'esistenza, la validita' e l'ammissibilita' del booking
  op_config_set = op_config['set'] || {}
  if name_function != 'get_operations' && op_config_set['booking_copy'] == true
    
   #segnalo errore: booking non presente (in O_LOAD imbarco con VUOTO posso non avere il booking)
   if hi.booking.nil? && !self.with_booking && (hi.container_FE != 'E' || hi.handling_item_type!= 'O_LOAD')
    ret[:is_valid] = false
    ret[:message]  = "Booking non presente" 
    return ret      
   end
   
   if !hi.booking.nil? && !self.with_booking 
     #segnalo errore: booking non valido (quantity o expiration...)   
     verifica_validazione = hi.booking.valida_insert_item(hi)
     if verifica_validazione[:is_valid] == false
      ret[:is_valid] = false
      ret[:message]  = verifica_validazione[:message] 
      return ret   
     end
   end
   
   if !hi.booking.nil? && self.with_booking
     ret[:is_valid] = false
     ret[:message]  = "Il movimento ha gia' un booking assegnato. Impossibile assegnarne un altro" 
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
  
  #memorizzo eventualmente il vecchio booking abbinato
  m_booking_id      = self.booking_id
  m_booking_item_id = self.booking_item_id
  
  #Elaboro le operazioni dichiarate in "set"
  op_config = h_type_config[hi.handling_item_type]
  op_config_set = op_config['set'] || {}

  for set_op_name, set_op_value in op_config_set 
   self.send("sincro_set_#{set_op_name}", set_op_value, hi)
  end
 
  #se presente riporto lo stato di lock
  unless (hi.lock_fl.nil?)
    self.lock_fl    = hi.lock_fl
    self.lock_type  = hi.lock_type
  end
  
 #salvo handling_header
 self.save!
 
 #se e' un handling_item che gestisce il booking, aggiorno lo stato del booking
 ret_booking = {} 
 
  if op_config_set['booking_copy'] == true && !hi.booking.nil?  
   ret_booking = hi.handling_header.booking.refresh_status(hi.booking_item)
  end
  if op_config_set['booking_reset'] == true
   if !m_booking_id.nil? && !m_booking_item_id.nil?
    b = Booking.find(m_booking_id)
    bi = BookingItem.find(m_booking_item_id)  
    ret_booking = b.refresh_status(bi)
   end
  end
 
 
 
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
def sincro_set_to_weigh(value, hi)
################################################################
  if (value == true || (value == 'IF_FULL' && hi.container_FE == 'F') || (value == 'IF_EMPTY' && hi.container_FE == 'E'))  
    hi.to_weigh = true
    hi.save!
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
 return if hi.booking.nil?
 b = Booking.find(hi.booking_id)
 self.booking_id  = hi.booking_id
 self.booking_item_id  = hi.booking_item_id
 self.num_booking = b.num_booking
end

################################################################
def sincro_set_booking_reset(value, hi)
################################################################
 if value == true
   self.booking_id  = nil
   self.booking_item_id  =  nil
   self.num_booking = nil
 end
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
def sincro_set_save_in_hi_weight_exp(value, hi)
################################################################
  if value == true
    hi.weight = self.weight_exp
    hi.save!
  end
end


################################################################
def sincro_set_with_booking(value, hi)
################################################################
end

################################################################
def sincro_set_handling_header_status(value, hi)
################################################################
 self.handling_status = value
end


################################################################
def sincro_set_handling_header_status_by_config(value, hi)
################################################################
 #chiudo in base ai parametri indicati sulla compagnia e in base al tipo di equipment (frigo o no) 
 #value contiene elenco parametri
 
  #se e' stato indicato shipowner_id verifico di essere in una compagnia di quelle elencate
  if !value[:shipowner_id].nil? 
    if !value[:shipowner_id].to_s.split(',').include? self.shipowner_id.to_s
      #logger.info "Esco perche' la compagnia non e' di quelle elencate"
      return false #esco perche' la shipwowner non e' di quelle elencate
    end
  end
    
  if !value[:reefer].nil?
    if self.equipment.reefer != value[:reefer]
      #logger.info "Non combacia reefer/non reefer"
      return false #esco perche' non combacia reefer/non reefer
    end 
  end

  if !value[:container_FE].nil?
    if self.container_FE.to_s != value[:container_FE]
      #logger.info "Non combacia container_FE"
      return false #esco perche' non combacia container_FE
    end 
  end  
  
  self.handling_status = value[:new_status]
end






################################################################
def sincro_set_auto_O_OTHER(value, hi)
################################################################
 #chiudo in base ai parametri indicati sulla compagnia e in base al tipo di equipment (frigo o no) 
 #value contiene elenco parametri
 
  #se e' stato indicato shipowner_id verifico di essere in una compagnia di quelle elencate
  if !value[:shipowner_id].nil? 
    if !value[:shipowner_id].to_s.split(',').include? self.shipowner_id.to_s
      #logger.info "[auto_O_OTHER] Esco perche' la compagnia non e' di quelle elencate"
      return false #esco perche' la shipwowner non e' di quelle elencate
    end
  end
    
  if !value[:reefer].nil?
    if self.equipment.reefer != value[:reefer]
      #logger.info "[auto_O_OTHER] Non combacia reefer/non reefer"
      return false #esco perche' non combacia reefer/non reefer
    end 
  end

  if !value[:container_FE].nil?
    if self.container_FE.to_s != value[:container_FE]
      #logger.info "[auto_O_OTHER] Non combacia container_FE"
      return false #esco perche' non combacia container_FE
    end 
  end  
  
  #creo in automatico l'uscita per altro terminal (in particolare per i pieni non gestiti)
  hi_O_OTHER = self.handling_items.new()
  hi_O_OTHER.handling_item_type = "O_OTHER"
  hi_O_OTHER.datetime_op = Time.now
  hi_O_OTHER.handling_type = "O"
  hi_O_OTHER.container_FE = hi.container_FE
  validate_insert_item = self.validate_insert_item(hi_O_OTHER)
  if validate_insert_item[:is_valid]    
    hi_O_OTHER.save!()
    r = self.sincro_save_header(hi_O_OTHER)
          
    ret_status  = r[:success]
    message     = r[:message]
  else
    ret_status  = validate_insert_item[:is_valid]
    message     = validate_insert_item[:message]
    raise ActiveRecord::RecordNotSaved
  end
end





################################################################
def sincro_set_operation_type(value, hi)
################################################################
 hi.operation_type = value
 hi.save!
end

################################################################
def sincro_set_start_reefer_connection(value, hi)
################################################################
  #verifico che l'equipment sia di tipo freeze e se necessario genero il movimento allaccio frigo
  if self.equipment.reefer == true
    if (value == true || (value == 'IF_FULL' && hi.container_FE == 'F') || (value == 'IF_EMPTY' && hi.container_FE == 'E'))
      #logger.info "Creo allaccio frigo (automatico)"
      hi_reefer = self.handling_items.new()
      hi_reefer.datetime_op = hi.datetime_op
      hi_reefer.operation_type = 'AF'
      hi_reefer.handling_item_type = 'FRCON'
      hi_reefer.save!
      #logger.info "Allaccio frigo creato (automatico) hi_id: #{hi_reefer.id.to_s} hh_id: #{self.id.to_s} -> verifico esistenza record"
      if hi_reefer.id.nil?
        #logger.info "ERRORE:::: Allaccio frigo: movimento non creato (automatico)"
        raise ActiveRecord::RecordNotSaved
      end
    end
  end 
end

################################################################
def sincro_set_end_reefer_connection(value, hi)
################################################################
  #se richiesto chiudo l'operazione di allaccio frigo per il container in corso (dettagli non ancora chiusi)
    if (value == true)
      self.handling_items.each do |hi_reefer|
        if hi_reefer.handling_item_type == 'FRCON' && hi_reefer.datetime_op_end.nil?
      	   #logger.info "Termino allaccio frigo"        
           hi_reefer.datetime_op_end = hi.datetime_op
           hi_reefer.save!
        end
      end
    end
end


################################################################
def sincro_set_lock_INSPECT(value, hi)
################################################################
    if (value == true || (value == 'IF_FULL' && hi.container_FE == 'F') || (value == 'IF_EMPTY' && hi.container_FE == 'E'))
      
      #solo se gia' non e' in lock
      if (hi.lock_fl.nil?)
        #logger.info "Setto lock INSPECT (da ispezionare)"
        hi.set_lock('INSPECT')
        hi.save!
      end
      
      #viene sempre eseguito in sincro_save_header
      #self.lock_fl    = hi.lock_fl
      #self.lock_type  = hi.lock_type 
    end 
end


################################################################
def sincro_set_clear_lock(value, hi)
################################################################
  self.lock_fl = false
  self.lock_type = nil  
end

################################################################
def get_lock_INSPECT_date
################################################################
  hi_INSPECT = HandlingItem.handlingHeader(self.id).locked_INSPECT.last
  hi_INSPECT.datetime_op if (hi_INSPECT)    
end
 
################################################################
def get_lock_DAMAGED_date
################################################################
  hi_DAMAGED = HandlingItem.handlingHeader(self.id).where('lock_type = ?', 'DAMAGED').last
  hi_DAMAGED.datetime_op if (hi_DAMAGED)    
end
 
################################################################
def get_lock_DAMAGED_AU_date
################################################################
  hi_DAMAGED_AU = HandlingItem.handlingHeader(self.id).where('lock_type = ?', 'DAMAGED_AU').last
  hi_DAMAGED_AU.datetime_op if (hi_DAMAGED_AU)    
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
def get_open_repair_handling_item
################################################################
  RepairHandlingItem.joins(:handling_item).where({handling_items: {handling_header_id: self.id}}).where("repair_status = 'OPEN'").first
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
