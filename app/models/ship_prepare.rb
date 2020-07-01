class ShipPrepare < ActiveRecord::Base
  
  belongs_to :customer
  belongs_to :ship
  belongs_to :pier
  has_many   :ship_prepare_items
  has_many   :ship_prepare_item_weighs, through: :ship_prepare_items
  has_many   :handling_items
  
  scope :not_closed, -> {where("ship_prepare_status NOT IN('CLOSE', 'PREP')")}
  
  
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
  def find_container_position(container_number)
    return nil if self.container_positions.nil?
    self.container_positions.each_line do |line|
       r = line.split("\t")
       return r[1].strip.to_s.rjust(6, '0') if r[0] == container_number        
    end
    return nil #non trovato
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
