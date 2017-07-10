class ShipPrepare < ActiveRecord::Base
  
  belongs_to :customer
  belongs_to :ship
  belongs_to :pier
  has_many   :ship_prepare_items
  has_many   :ship_prepare_item_weighs, through: :ship_prepare_items
  
  scope :not_closed, -> {where("ship_prepare_status NOT IN('CLOSE', 'PREP')")}
  
  def self.as_json_prop()
      return { 
        :include=>{
           :customer  => {},
           :ship  => {},
           :pier  => {}
           }
         }       
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
