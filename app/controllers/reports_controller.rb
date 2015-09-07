class ReportsController < ApplicationController
  layout "application_report"
   
 def handlings_parameters
  @hh = HandlingHeader.new
  @hi = HandlingItem.new
 end    

  def handlings_inspe_parameters
   @hh = HandlingHeader.new
   @hi = HandlingItem.new
  end    

  def handlings_rfcon_parameters
   @hh = HandlingHeader.new
   @hi = HandlingItem.new
  end    

 def handlings_rfcon_check_temp_parameters
   @hh = HandlingHeader.new
   @hi = HandlingItem.new
 end    

  def handlings_ship_voyage_parameters
   @hh = HandlingHeader.new
   @hi = HandlingItem.new
  end    

  
  
   
 def in_terminal_parameters
  @hh = HandlingHeader.new
  @hi = HandlingItem.new
 end    


 def booking_open_parameters
  @hh = HandlingHeader.new
  @hi = HandlingItem.new
  @bh = Booking.new
  @bi = BookingItem.new
 end    
 
  
   
 def handlings_sint
 end  
 
 def handlings_analytic
 end  

  def handlings_inspe_sint
  end  
  
  def handlings_inspe_analytic
  end  


  def handlings_rfcon_sint
  end  
  
  def handlings_rfcon_analytic
  end  

  def handlings_ship_voyage_sint
  end  
  
  def handlings_ship_voyage_analytic
  end  
 
    

  def in_terminal_sint
  end  
  
  def in_terminal_analytic
  end  
 

  def booking_open_analytic
  end 
  def booking_open_sint
  end  
    
  
   
end
