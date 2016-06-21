class RepairEstimateItem < ActiveRecord::Base
  belongs_to :repair_handling_item
  belongs_to :repair_processing
  

  #ToDo: DRY  
  def repair_processing_name
   if self.repair_processing.nil?
    return '#PROC_DELETE#'
   else 
    return [ self.repair_processing.repair_position.nil? ? '#DEL#' : self.repair_processing.repair_position.description_it, 
      self.repair_processing.repair_component.nil? ? '#DEL#' : self.repair_processing.repair_component.description_it, 
      self.repair_processing.description_it.to_s].join(' | ')
   end   
  end
 
  
  def code1
    if self.repair_processing.nil?
      return '#PROC_DELETE#'
    else
      price_row = RepairPrice.where(:repair_processing_id => self.id).where(:shipowner_id => self.repair_handling_item.handling_item.handling_header.shipowner_id).first
      if price_row.nil?
        return 'not found'
      else
        return price_row.code1.to_s 
      end
    end
  end
  
  def code2
    if self.repair_processing.nil?
      return '#PROC_DELETE#'
    else
      price_row = RepairPrice.where(:repair_processing_id => self.id).where(:shipowner_id => self.repair_handling_item.handling_item.handling_header.shipowner_id).first
      if price_row.nil?
        return 'not found'
      else
        return price_row.code2.to_s 
      end
    end
  end  

  
    
  def code1_code2
    if self.repair_processing.nil?
      return '#PROC_DELETE#'
    else
      price_row = RepairPrice.where(:repair_processing_id => self.repair_processing_id).where(:shipowner_id => self.repair_handling_item.handling_item.handling_header.shipowner_id).first
      if price_row.nil?
        return 'not found'
      else
        return price_row.code1.to_s + " - " + price_row.code2.to_s 
      end
    end
  end

  
  #ricopio i dati contabili da processing e compagnia
  def set_auto_data(repair_price)
    self.provider_time = repair_price.provider_time
    self.provider_material_price = repair_price.provider_material_price
    
    self.customer_time = repair_price.customer_time
    self.customer_material_price = repair_price.customer_material_price    
  end
  
  
  
  def shipowner
    self.repair_handling_item.handling_item.handling_header.shipowner
  end
  
  def self.as_json_prop()
      return {
         :include=>{
            :repair_processing => {},
            },
         :methods=>[:repair_processing_name, :code1_code2, :shipowner]
         }
  end
  
  
end
