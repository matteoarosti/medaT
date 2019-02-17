class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  #forza l'autenticazione (devise) - rimanda sempre alla pagina di login
  before_action :authenticate_user!, :set_current_user
  
    
  require "#{Rails.root}/lib/extjs_sc_utility.rb"
 
  
  
  #devise: path after login
  #costruisco 
  def DDDDDDDDDafter_sign_in_path_for(resource)
    ####es: user_path(current_user) (pagina show per user)
    
    #in base all'utente (role) costruisco la pagina da visualizzare    
    url_for('/terminal_movs/index')    
  end  
  
  
  ###################################################################
  # EXTJS SCAFFOLD
  ###################################################################
  def extjs_sc_crt_tab
    logger.info params.to_yaml
    model_class = extjs_sc_model.to_s  
    sc_columns = model_class.constantize.extjs_sc_columns        
    sc_form_fields = model_class.constantize.extjs_sc_form_fields
    render :partial=>"/extjs_sc/sc_crt_tab", :locals=>{
        :sc_model_class => model_class,
        :sc_columns     => sc_columns, 
        :sc_form_fields => sc_form_fields, 
        :sc_store       => sc_crt_store(),
        :on_open_tab_id => params[:on_open_tab_id]
    }  
  end
  
  #apertura form filtri
  def extjs_sc_crt_filter_view
    model_class = extjs_sc_model.to_s
    @item = model_class.constantize.new
  end
  
 
  def get_combo_data
    ret = {}
    model_class = extjs_sc_model.to_s
    ret[:success] = true
    ret[:items] = model_class.constantize.order(model_class.constantize.combo_displayField()).limit(500)
    render json: ret
  end
  
  
  ##########################################
   def extjs_sc_list
  ########################################## 
    model_class = extjs_sc_model.to_s
      
    ret = {}
    ret[:items] = model_class.constantize.extjs_default_scope
      
    #gestione eventuali filtri
    unless params[:my_filters].nil?
      ret[:items] = model_class.constantize.extjs_sc_list_add_default_join_on_my_filters(ret[:items])
      params[:my_filters].each do |kp, p|
        ret[:items] = ret[:items].where("#{kp} = ?", p) unless p.blank?
      end
    end  
      
        
    ret[:items] = ret[:items].limit(params[:limit]).offset(params[:start]).as_json(model_class.constantize.as_json_prop)
    ret[:total] = model_class.constantize.extjs_default_scope.count
    
    render json: ret
   end  
  
  
  ########################################## 
   def sc_read
  ##########################################   
    item = extjs_sc_model.constantize.find(params[:id])
    render json: {:success => true, :data=>item.as_json(extjs_sc_model.constantize.as_json_prop)}
   end  

  ########################################## 
   def sc_update
  ########################################## 
  
    item = extjs_sc_model.constantize.find(params[:data][:id])
    params[:data].permit!
    item.update(params[:data])
    item.save!()
    render json: {:success => true, :data=>[item.as_json(extjs_sc_model.constantize.as_json_prop)]}
   end 
  
  ########################################## 
   def sc_create
  ########################################## 
    item = extjs_sc_model.constantize.new()    
    params[:data].permit!
    #filtro solo gli attributi presenti nel model e salvo
    create_params = params[:data].select{|k,v| extjs_sc_model.constantize.column_names.include? k}
    item.update(create_params)
    item.save!()
    render json: {:success => true, :data=>[item.as_json(extjs_sc_model.constantize.as_json_prop)]}
   end   
  
  ########################################## 
   def extjs_sc_destroy
  ########################################## 
   if !params[:data].kind_of?(Array)
    item = extjs_sc_model.constantize.find(params[:data][:id])
    item.destroy() #delete non elimina has_many in cascata
   else
    params[:data].each do |rec|
      item = extjs_sc_model.constantize.find(rec[:id])
      item.destroy() #delete non elimina has_many in cascata    
    end
   end 
    render json: {:success => true}
   end  
  
  
  
  
  
  
 def sc_crt_store
  ret = {}
  ret[:xtype] = 'Ext.data.Store'
  ret[:autoLoad] = true
  ret[:autoSync] = false
  ret[:autoDestroy] = true
  ret[:proxy] = sc_crt_proxy
  ret[:model] = extjs_sc_model.to_s
  ret[:pageSize] = 500
  ret[:leadingBufferZone] = 300
  ret[:buffered] = false  
  return ret
 end 
 
 def sc_crt_proxy
  ret = {}
  ret[:url] = url_for(:action=>'extjs_sc_list')
  ret[:method] = 'POST'
  ret[:type] = 'ajax'
  ret[:paramsAsJson] = true
  
  ###ret[:actionMethods] = 'POST'
  ret[:actionMethods] = {
     :read => 'POST',
     :create => 'POST',
     :update => 'POST',
     :destroy => 'POST'
  }

  
  
  ret[:reader] = {:type => 'json', :method => 'POST', :rootProperty=>'items', :totalProperty=> 'total'}
  ret[:writer] = {:type => 'json', :rootProperty => 'data', :writeAllFields=>true,
              :getRecordData => "function (record){
                return { 'data': Ext.JSON.encode(record.data) };
            }"}
  ret[:api] = {
    :read   => url_for(:action=>'extjs_sc_list'),
    :create => url_for(:action=>'extjs_sc_create'),
    :update => url_for(:action=>'extjs_sc_update'),   
    :destroy=> url_for(:action=>'extjs_sc_destroy'),
    :save   => url_for(:action=>'extjs_sc_update'),
  }
  return ret
 end  
  
  
 def generate_datetime(data, time)
  Time.zone.parse(data + ' ' + time)
 end
 
  def set_current_user
    User.current = current_user
  end
  
  
  
  def merge_email_to(*p)
    p.join(';')
  end
    
end
