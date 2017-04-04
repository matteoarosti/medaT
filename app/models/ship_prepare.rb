class ShipPrepare < ActiveRecord::Base
  
  belongs_to :customer
  belongs_to :ship
  has_many   :ship_prepare_items
  
  scope :not_closed, -> {where("ship_prepare_status <> ?", 'CLOSE')}
  
  def self.as_json_prop()
      return { 
        :include=>{
           :customer  => {},
           :ship  => {}
           }
         }       
  end     
  
  
  
#valori per combo
def status_get_data_json
 [
  {:cod=>'OPEN',     :descr=>'Aperto'},
  {:cod=>'CLOSE',    :descr=>'Chiuso'},
  {:cod=>'EDIT',     :descr=>'In preparazione'}
 ]
end 
  

end
