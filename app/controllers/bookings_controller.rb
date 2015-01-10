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
 
 
 #create or save
 def sc_create

  if params[:data][:id].empty?
   item = Booking.new   
  else
   item = Booking.find(params[:data][:id])   
  end
 
  to_save_params = params[:data].select{|k,v| Booking.column_names.include?(k) && k != 'id'}  
  to_save_params.permit!
  item.update(to_save_params)
  
  #verifico validita' quantity
  if item.get_num_impegni() > item.quantity
   render json: {:success => false, :message=>"La quantità indicata è inferiore al numero dei movimenti attualmnete abbinati al booking"}
   return
  end
  
  item.save!()  
  render json: {:success => true, :data=>[item.as_json(Booking.as_json_prop)]}  
  
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
 

end
