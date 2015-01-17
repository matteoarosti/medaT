class ReportsController < ApplicationController
  layout "application_report"
   
 def handlings_parameters
  @hh = HandlingHeader.new
  @hi = HandlingItem.new
 end    
  
 def handlings_sint
 end  
 
 def handlings_analytic
 end  
 
  
end
