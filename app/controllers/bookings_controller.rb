class BookingsController < ApplicationController

 def extjs_sc_model
  'Booking'
 end  

 def form_new
  @item = Booking.new
  render :partial => 'form'
 end

end
