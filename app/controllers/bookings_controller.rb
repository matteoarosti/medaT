class BookingsController < ApplicationController

 def extjs_sc_model
  'Booking'
 end  

 ###################################################
 #ELIMINAZIONE
 ###################################################
 def extjs_sc_destroy
   success = false
   #verifico che non sia usato in nessun movimento
   @item = Booking.find(params[:data][:id]) 
   num_impegni_tot_booking = @item.get_num_impegni_tot()
   if num_impegni_tot_booking > 0
    success = false
    message = 'Attenzione! Ci sono movimenti abbinati'
   else
    #info: delete non esegue il destroy in cascata dei booking_items
    @item.destroy      
    success = true
    message = ''
   end
   
    render json: {:success => success, :message=>message}     
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
  else
   item = Booking.find(params[:data][:id])   
  end
 
  #se cambio il num_booking verifico che non sia gia' un valore presente
  if item.num_booking != params[:data][:num_booking]
    b = Booking.get_by_num(params[:data][:num_booking])
    if !b.nil?
      render json: {:success => false, :message => "Numero Booking gia' presente."}
      return
    end
  end
  
  to_save_params = params[:data].select{|k,v| Booking.column_names.include?(k) && k != 'id'}  
  to_save_params.permit!
  item.update(to_save_params)

  item.save!()
  
  #se e' cambiato il num_booking lo aggiorno anche negli handling_headers abbinati
  item.handling_headers.each do |hi|
    if (hi.num_booking != item.num_booking)
      hi.num_booking = item.num_booking
      hi.save!
    end
  end
    
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
  
   #verifico che l'equipment non sia gia' presente nel booking
   is_present = BookingItem.get_by_booking_eq(params[:data][:booking_id], params[:data][:equipment_id])
   if is_present
    render json: {:success => false, :message => "Equipment gia' presente"}
    return
   end
  
 else
  item = BookingItem.find(params[:data][:id])
    
   #verifico validita' quantity 
   if item.booking.get_num_impegni(item.id) > params[:data][:quantity].to_i
    render json: {:success => false, :message=>"La quantità indicata è inferiore al numero dei movimenti attualmnete abbinati al booking"}
    return
   end 
       
 end

 
 to_save_params = params[:data].select{|k,v| BookingItem.column_names.include?(k) && k != 'id'}  
 to_save_params.permit!
 item.update(to_save_params)
 
 item.save!()  
 render json: {:success => true, :data=>[item.as_json(BookingItem.as_json_prop)]}
end



def bitems_form_new
 @item = BookingItem.new
 @item.status = 'OPEN'
 @item.booking_id = params[:booking_id]
 render :partial => 'bitems_form', :locals=>{:op => 'CREATE'}
end

#TODO: verificare quantita' ammesse
def bitems_form_edit
 @item = BookingItem.find(params[:id])
 render :partial => 'bitems_form', :locals=>{:op => 'EDIT'}
end

#TODO: prima di eliminazione verificare che non sia utilizzato
def bitems_sc_destroy
 @item = BookingItem.find(params[:data][:id])
 @item.delete
  render json: {:success => true}
end


def bitem_info
  @item = BookingItem.find(params[:rec_id])
end  

end
