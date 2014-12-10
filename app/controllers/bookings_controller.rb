class BookingsController < ApplicationController

 def extjs_sc_model
  'Booking'
 end  

 def form_new
  @item = Booking.new
  render :partial => 'form'
 end
 
 def form_edit
  @item = Booking.find(params[:rec_id])
  render :partial => 'form'
 end


 
 def form_search
 end
 
 
 
#############################################################
def search_num_booking
#############################################################
  ret = {}
   ret[:items] = Booking.like_num_booking(params[:num_booking]).limit(1000).as_json(Booking.as_json_prop)
   ret[:success] = true
   render json: ret
end
 

end
