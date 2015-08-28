class ToDoItem < ActiveRecord::Base
  
  belongs_to :equipment
  belongs_to :carrier
  belongs_to :shipowner
  
  #obbligatorio per extjs_sc
  scope :extjs_default_scope, -> { }    
  scope :not_closed, -> {where("status <> ?", 'CLOSE')}
  scope :prenotazione_container, -> {where("to_do_type = ?", 'CONT_PRE_ASS')}    
    
  def self.as_json_prop()
      return {
         :include=>{
            :equipment => {:only=>[:equipment_type]},
            :carrier => {:only=>[:name]},
            :shipowner => {:only=>[:name]}
            }
         }
  end
    
    
    
    
  def to_do_type_get_data_json
   [
    {:cod=>'CONT_PRE_ASS', :descr=>'Prenotazione container'}
   ]
  end    
  
  def handling_item_type_get_data_json
   [
    {:cod=>'O_FILLING', :descr=>'Uscita per riempimento'}
   ]
  end


  def handling_type_get_data_json
   [
    {:cod=>'I', :descr=>'Ingresso'},
    {:cod=>'O', :descr=>'Uscita'}
   ] 
  end 

  
    
  def status_get_data_json
   [
    {:cod=>'OPEN', :descr=>'Open'},
    {:cod=>'CLOSE', :descr=>'Close'}
   ] 
  end 
      

  #valori per combo
  def container_FE_get_data_json
   [
    {:cod=>'F', :descr=>'Full'},
    {:cod=>'E', :descr=>'Empty'}
   ]
  end     
  
    
end
