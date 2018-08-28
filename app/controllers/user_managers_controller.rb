class UserManagersController < ApplicationController

  def extjs_sc_model
    'User'
  end
  
  def w_chg_user_psw
  end
  
  def chg_user_psw
    @item = User.find(params[:data][:user_id])
    @item.password = params[:data][:password]
    @item.password_confirmation = params[:data][:password_confirmation]
    begin
      @item.save!()    
      render json: {:success => true}
    rescue
      logger.info @item.errors.to_yaml
     render json: {:success => false, message: 'Password non coincidenti o non valida (min 8 caratteri)'}
    end
  end
  
  ########################################## 
   def sc_create
  ########################################## 
    item = extjs_sc_model.constantize.new()    
    params[:data].permit!
    #filtro solo gli attributi presenti nel model e salvo
    create_params = params[:data].select{|k,v| extjs_sc_model.constantize.column_names.include? k}
    item.update(create_params)
    
    generated_password = Devise.friendly_token.first(8)
    item.password = generated_password
    item.password_confirmation = generated_password
    begin
      item.save!()    
      render json: {:success => true, :data=>[item.as_json(extjs_sc_model.constantize.as_json_prop)]}
    rescue
     render json: {:success => false}
    end     
   end   


end
