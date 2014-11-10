class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  #forza l'autenticazione (devise) - rimanda sempre alla pagina di login
  before_action :authenticate_user!
  
    
  require "#{Rails.root}/lib/extjs_sc_utility.rb"
  
  
  
  ###################################################################
  # EXTJS SCAFFOLD
  ###################################################################
  def extjs_sc_crt_tab
    model_class = extjs_sc_model.to_s  
    sc_columns = model_class.constantize.extjs_sc_columns        
    sc_form_fields = model_class.constantize.extjs_sc_form_fields
    render :partial=>"/extjs_sc/sc_crt_tab", :locals=>{:sc_columns => sc_columns, :sc_form_fields => sc_form_fields, :sc_store => sc_crt_store()}  
  end
  
  
  ##########################################
   def extjs_sc_list
  ########################################## 
    model_class = extjs_sc_model.to_s
      
    ret = {}
    ret[:items] = model_class.constantize.limit(params[:limit]).offset(params[:start])
    ret[:total] = model_class.constantize.count
    render json: ret
   end  
  

  ########################################## 
   def sc_update
  ########################################## 
    item = extjs_sc_model.constantize.find(params[:data][:id])
    params[:data].permit!
    item.update(params[:data])
    item.save!()
    render json: {:success => true, :data=>[item]}
   end 
  
  ########################################## 
   def sc_create
  ########################################## 
    item = extjs_sc_model.constantize.new()
    params[:data].permit!
    item.update(params[:data])
    item.save!()
    logger.info item.to_yaml
    render json: {:success => true, :data=>[item]}
   end   
  
  ########################################## 
   def extjs_sc_destroy
  ########################################## 
   if !params[:data].kind_of?(Array)
    item = extjs_sc_model.constantize.find(params[:data][:id])
    item.delete()
   else
    params[:data].each do |rec|
      item = extjs_sc_model.constantize.find(rec[:id])
      item.delete()    
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
  ret[:actionMethods] = 'POST'
  
  
  ret[:reader] = {:type => 'json', :method => 'POST', :rootProperty=>'items', :totalProperty=> 'total'}
  ret[:writer] = {:type => 'json', :rootProperty => 'data', :writeAllFields=>true,
              :getRecordData => "function (record)
            {
              console.log('getRecordData2222');
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
  
  
  
  
    
end
