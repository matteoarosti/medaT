class BookingsController < ApplicationController

 def extjs_sc_model
  'Booking'
 end  

 def form_new
  @item = Booking.new
  @item.status = 'OPEN'
  render :partial => 'form', :locals=>{:op => 'CREATE'}
 end
 
 def form_edit
  @item = Booking.find(params[:rec_id])
  render :partial => 'form', :locals =>{:op => 'UPDATE'}
 end

 
 def form_search
 end
 
  def to_check
  end
 
 
 #create or save
 def sc_create

  if params[:data][:id].empty?
   item = Booking.new
   
   #al numero container aggiunto il codice equipment (es: 40DV)
   # ora e' gestito in booking_items
   ##eq = Equipment.find(params[:data][:equipment_id])
   ##params[:data][:num_booking]+= eq.equipment_type.to_s
      
  else
   item = Booking.find(params[:data][:id])   
  end
 
  to_save_params = params[:data].select{|k,v| Booking.column_names.include?(k) && k != 'id'}  
  to_save_params.permit!
  item.update(to_save_params)
      
  #verifico validita' quantity
  # ora e' in bookin_items
  ##if item.get_num_impegni() > item.quantity
  ## render json: {:success => false, :message=>"La quantità indicata è inferiore al numero dei movimenti attualmnete abbinati al booking"}
  ## return
  ##end
  
  item.save!()  
  render json: {:success => true, :data=>[item.as_json(Booking.as_json_prop)]}  
  
 end
 
 
# List per grid dettagli (equipment/quantity)
##################################################
def bitems_sc_list  
##################################################
  ret = {}
   ret[:items] = BookingItem.forBookingId(params[:booking_id]).limit(1000).as_json(BookingItem.as_json_prop)
   ret[:success] = true
   render json: ret 
end
 
 
 
#############################################################
def search_num_booking
#############################################################
  ret = {}
   bk = Booking.where('1=1')
   bk = bk.like_num_booking(params[:num_booking])
   bk = bk.where('status = ?', params[:status])  unless params[:status].blank?
   #ret[:items] = Booking.like_num_booking(params[:num_booking]).limit(1000).as_json(Booking.as_json_prop)
   ret[:items] = bk.limit(1000).as_json(Booking.as_json_prop)
   ret[:success] = true
   render json: ret
end


#############################################################
def to_check_get_data
#############################################################
  ret = {}
   bk = Booking.where('1=1')
   bk = bk.to_check()
   ret[:items] = bk.limit(1000).as_json(Booking.as_json_prop)
   ret[:success] = true
   render json: ret
end
 

###################################################################
# Bookin Items
###################################################################

#create or save
def bitems_sc_create

 if params[:data][:id].empty?
  item = BookingItem.new
  item.status = 'OPEN'       
 else
  item = BookingItem.find(params[:data][:id])   
 end

 to_save_params = params[:data].select{|k,v| BookingItem.column_names.include?(k) && k != 'id'}  
 to_save_params.permit!
 item.update(to_save_params)
     
 #TODO
 #verifico validita' quantity
 # ora e' in bookin_items
 ##if item.get_num_impegni() > item.quantity
 ## render json: {:success => false, :message=>"La quantità indicata è inferiore al numero dei movimenti attualmnete abbinati al booking"}
 ## return
 ##end
 
 item.save!()  
 render json: {:success => true, :data=>[item.as_json(BookingItem.as_json_prop)]}  
 
end



def bitems_form_new
 @item = BookingItem.new
 @item.status = 'OPEN'
 @item.booking_id = params[:booking_id]
 render :partial => 'bitems_form', :locals=>{:op => 'CREATE'}
end


end
