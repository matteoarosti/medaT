class HandlingHeadersController < ApplicationController

 def extjs_sc_model
  'HandlingHeaders'
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



end
