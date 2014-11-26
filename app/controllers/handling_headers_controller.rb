class HandlingHeadersController < ApplicationController

 def extjs_sc_model
  'HandlingHeader'
 end 


##################################################
def sc_create  #OVERRIDE DEL METODO STANDARD
##################################################
    item = extjs_sc_model.constantize.new()    
    params[:data].permit!
    #filtro solo gli attributi presenti nel model e salvo
    create_params = params[:data].select{|k,v| extjs_sc_model.constantize.column_names.include? k}
    create_params[:handling_status] = 'NEW'
    item.update(create_params)
    item.save!()
    render json: {:success => true, :data=>[item.as_json(extjs_sc_model.constantize.as_json_prop)]}
end





# Visualizzazione grid dettagli
##################################################
def hitems_sc_list  
##################################################
  ret = {}
   ret[:items] = HandlingItem.handlingHeader(params[:handling_id]).limit(1000).as_json(HandlingItem.as_json_prop)
   ret[:success] = true
   render json: ret 
end


# Inserimento dettaglio movimento
##################################################
def hitems_sc_create  
##################################################
   hh = HandlingHeader.find(params[:data][:handling_header_id])
   hi = hh.handling_items.new()

   params[:data].permit!
   hi.assign_attributes(params[:data])

   #se supera i vari controlli salvo il dettalio e aggiorno la testata
   if hh.validate_insert_item(hi)[:is_valid]
    hi.save!()
    hh.sincro_save_header(hi)
    ret_status = true
   else
    ret_status = false
   end 
       
   render json: {:success => ret_status} 
end



end
