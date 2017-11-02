class ClearShipsList  
  
  def test(ship_id_from, ship_id_to)
    
    ship_from = Ship.find(ship_id_from)
    ship_to   = Ship.find(ship_id_to)
    
    puts "From: #{ship_from.name.to_s}, shipowner: #{!ship_from.shipowner.nil? ? ship_from.shipowner.name.to_s : 'NON DEFINITA'}"
    puts "To: #{ship_to.name.to_s}, shipowner: #{!ship_to.shipowner.nil? ? ship_to.shipowner.name.to_s : 'NON DEFINITA'}"
    
    #conteggio Bookings
    puts "Bookings        from: n: #{ship_from.bookings.count},      to: #{ship_to.bookings.count}"
    puts "HandlingItems   from: n: #{ship_from.handling_items.count},      to: #{ship_to.handling_items.count}"
    puts "ImportHeaders   from: n: #{ship_from.import_headers.count},      to: #{ship_to.import_headers.count}"
    puts "ToDoItems       from: n: #{ship_from.to_do_items.count},      to: #{ship_to.to_do_items.count}"
    puts "ShipPrepares    from: n: #{ship_from.ship_prepares.count},      to: #{ship_to.ship_prepares.count}"    

  end #test
  
  def execute(ship_id_from, ship_id_to)
    ship_from = Ship.find(ship_id_from)
    ship_from.bookings.update_all(ship_id: ship_id_to)
    ship_from.handling_items.update_all(ship_id: ship_id_to)
    ship_from.import_headers.update_all(ship_id: ship_id_to)
    ship_from.to_do_items.update_all(ship_id: ship_id_to)
    ship_from.ship_prepares.update_all(ship_id: ship_id_to)
    ship_from.name = "[*** -> #{ship_id_to}] #{ship_from.name}"
    ship_from.save!
  end
  
end #class
