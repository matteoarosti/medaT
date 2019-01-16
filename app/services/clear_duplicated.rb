class ClearDuplicated
  
  
  
  ##############################################
  # SHIPOWNER
  ##############################################
  def test_shipowner(id_from, id_to)
    test_record("shipowner", %w(activities bookings codeco_sends handling_headers import_items repair_prices ships to_do_items weighs), id_from, id_to)
  end
  def update_shipowner(id_from, id_to)
    update_record("shipowner", %w(activities bookings codeco_sends handling_headers import_items repair_prices ships to_do_items weighs), id_from, id_to)
  end
  

  
  ##############################################
  # SHIP
  ##############################################
  def test_ship(id_from, id_to)
    test_record("ship", %w(bookings handling_items import_headers to_do_items ship_prepares), id_from, id_to)
  end
  def update_ship(id_from, id_to)
    update_record("ship", %w(bookings handling_items import_headers to_do_items ship_prepares), id_from, id_to)
  end

    
  ##############################################
  # CUSTOMER
  ##############################################
  def test_customer(id_from, id_to)
    test_record("customer", %w(activities ship_prepares weighs), id_from, id_to)
  end
  def update_customer(id_from, id_to)
    update_record("ship", %w(activities ship_prepares weighs), id_from, id_to)
  end
  

  
  
  # FUNZIONI UTILITY STD #    
  
  
  ############################################
  # test STD
  ############################################    
  def test_record(entity_name, table_list, id_from, id_to)    
    rec_from = Object.const_get( entity_name.camelize ).find(id_from)
    rec_to   = Object.const_get( entity_name.camelize ).find(id_to)
    
    puts "From: (#{id_from}) #{rec_from.name.to_s}"
    puts "To:   (#{id_to}) #{rec_to.name.to_s}"
    
    #conteggio Bookings
    table_list.each do |t|
      classConst = Object.const_get( t.singularize.camelize ) 
      puts "#{sprintf("%30s", t)}   from: n: #{classConst.where("#{entity_name}_id = #{id_from}").count},       to: #{classConst.where("#{entity_name}_id = #{id_to}").count}"
    end

  end #test
  
  
  ############################################
  # execute STD
  ############################################
  def update_record(entity_name, table_list, id_from, id_to)    
    rec_from = Shipowner.find(id_from)
    rec_to   = Shipowner.find(id_to)
    
    puts "From: (#{id_from}) #{rec_from.name.to_s}"
    puts "To:   (#{id_to}) #{rec_to.name.to_s}"
    
    #conteggio Bookings
    table_list.each do |t|
      classConst = Object.const_get( t.singularize.camelize )       
      classConst.where("#{entity_name}_id = #{id_from}").update_all("#{entity_name}_id = #{id_to}")      
    end
    rec_from.name = "[*** -> #{id_to}] #{rec_from.name}"
    rec_from.save!

  end #test
  
  
    
  
end #class
