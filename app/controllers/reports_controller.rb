class ReportsController < ApplicationController
  layout "application_report"
   
 def handlings_parameters
  @hh = HandlingHeader.new
  @hi = HandlingItem.new
 end    

 def in_terminal_parameters
  @hh = HandlingHeader.new
  @hi = HandlingItem.new
 end    

 
   
 def handlings_sint
 end  
 
 def handlings_analytic
 end  
 

  def in_terminal_sint
  end  
  
  def in_terminal_analytic
  end  
 
   
end
