class BookingsController < ApplicationController

 def extjs_sc_model
  'Booking'
 end  

 def form_new
  @item = Booking.new
  render :partial => 'form', :locals=>{:op => 'CREATE'}
 end
 
 def form_edit
  @item = Booking.find(params[:rec_id])
  render :partial => 'form', :locals =>{:op => 'UPDATE'}
 end

 
 def form_search
 end
 
 
 #create or save
 def sc_create

  if params[:data][:id].empty?
   item = Booking.new   
  else
   item = Booking.find(params[:data][:id])   
  end
 
  to_save_params = params[:data].select{|k,v| Booking.column_names.include?(k) && k != 'id'}
  logger.info to_save_params.to_yaml  
  to_save_params.permit!
  item.update(to_save_params)
  item.save!()  
  render json: {:success => true, :data=>[item.as_json(Booking.as_json_prop)]}  
  
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
