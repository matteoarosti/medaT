class CustomInspectionsController < ApplicationController


  #inserimento nuova richiesta
  def new_request
    @item = Activity.new
    render :partial => "new_request"
  end
    
  
  ####################################################     
  def exe_save
  ####################################################    
    to_h_data = params.dup  #clono perche' altrimenti non ritrovo i valori rimossi con delete    
    to_h_data.except!("container_number", "authenticity_token", "controller", "action").permit!
    
    item = Activity.new
    item.activity_type_id = ActivityType.find_by_code('CUST_INSPECTION').id
    item.update(to_h_data)
    
    #scrivo le righe di dettagli containers
    params["container_number"].each do |c|
      if !c.strip.blank?
        item.activity_dett_containers.new(container_number: c.strip)
      end
    end    
    
    item.save!()
    render json: {:success => true}
  end
  
  
  
  ##### DETTAGLI ########################################################
  def activity_dett
    @item = Activity.find(params[:rec_id])      
  end
  
  def activity_dett_list
    @item = Activity.find(params[:activity_id])
    @item_detts = @item.activity_dett_containers
    
    if params[:set_amount] == true
      #preimposto (se presente) il prezzo di default dell'attivita', a meno che non abbia gia' un prezzo sul dettaglio
      @item_detts.collect! { |ad|         
         ad.op_amount = @item.activity_op.default_price.to_i if ad.op_amount.nil?
      }
    end    
      
    render json: {:success => true, items: @item_detts}
  end
  
  def set_available
    item = ActivityDettContainer.find(params[:rec_id])
    item.make_available_at      = Time.zone.now    
    item.make_available_notes   = params[:check_form][:notes] unless params[:check_form].nil?       
    item.make_available_user_id = current_user.id
    item.save!
    render json: {:success => true}
  end
  
  def set_execution
    item = ActivityDettContainer.find(params[:rec_id])
    item.execution_at      = Time.zone.now
    item.execution_date    = Time.zone.now
    item.execution_notes   = params[:check_form][:notes]       
    item.execution_user_id = current_user.id    
    item.save!
    render json: {:success => true}
  end
  
  def add_container_to_activity_dett
    item = Activity.find(params[:activity_id])
    item.activity_dett_containers.new(container_number: params[:check_form][:container_number])
    item.save!  
    render json: {:success => true}
  end  
  
  
  ##################################################
   def modify_record
  ##################################################
    @item = ActivityDettContainer.find(params[:rec_id])    
    @from_component_id = params[:from_grid_id]
   end
   
  ##################################################
   def exe_modify_record
  ##################################################
    item = ActivityDettContainer.find(params[:data][:id])    
    params[:data].permit!
    item.update(params[:data])
    ret = item.save!  
    render json: {success: ret}
   end   

  
end #class
