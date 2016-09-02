class UtilitiesBase
  
  def shipowner_on_weighs
    #recupero tutti gli hi di cui ancora devo inviare la email (se necessario)
    Weigh.where('handling_item_id  IS NOT NULL').each do |item|
      print "\n----------------------------\n"
      print item.to_yaml
      if !item.handling_item.nil?
        item.shipowner_id = item.handling_item.handling_header.shipowner_id
        item.save!        
      end
    end
  end #shipowner_on_weighs
  
  

  def repair_total_cost_recalc
    items = RepairHandlingItem.where('estimate_authorized_at is not null')
    items.each.do |item|
     item.calculate_total_on_estimate
     item.calculate_total_on_authorized
     item.save!
    end
  end 
  
  
end #class
