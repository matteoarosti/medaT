class ActivitiesController < ApplicationController
  
  layout "application_report", only: [:report_by_customer]
  
  def create_new
    @item = Activity.new
  end
  
  def create_new_exe
    item = Activity.new
    params[:data].permit!
    item.update(params[:data])
    item.save!()
    render json: {:success => true, :data=>[item.as_json(Activity.as_json_prop)]}    
  end
  

  def set_execution
    item = Activity.find(params[:data][:id])
    params[:data].permit!
    item.update(params[:data])
    item.execution_date = Time.zone.now if item.execution_date.nil?
    item.execution_at   = Time.zone.now
    item.execution_user_id = current_user.id
    item.save!()
    render json: {:success => true, :data=>[item.as_json(Activity.as_json_prop)]}    
  end
  
  def set_amount
    item = Activity.find(params[:data][:id])
    params[:data].permit!
    item.update(params[:data])
    item.save!()
    render json: {:success => true, :data=>[item.as_json(Activity.as_json_prop)]}    
  end
    
  
  
  
  
  #######################################################
  # ELENCO
  #######################################################
  
  ##################################################
   def list
  ##################################################  
     render :partial=>"list", :locals => {:filtered_type => params[:filtered_type] , :on_open_tab_id => params[:on_open_tab_id]}
   end

   
##################################################
 def get_row_by_filtered_type
##################################################
   
   items = Activity.all #.where('repair_status=?', 'OPEN')
   
   #applico filtri impostati da utente
#   items = items.where("container_number LIKE ?", "%#{params[:form_user][:flt_num_container].upcase}%") if !params[:form_user][:flt_num_container].to_s.empty?
        

   
   items = items.where("created_at >= ?", Time.zone.parse(params[:form_user]['flt_date_from']).beginning_of_day) unless params[:form_user]['flt_date_from'].blank?
   items = items.where("created_at <= ?", Time.zone.parse(params[:form_user]['flt_date_to']).end_of_day) unless params[:form_user]['flt_date_to'].blank?
   
   case params[:filtered_type]           
     
     when 'OPEN'
       items = items.where('execution_date IS NULL')

     when 'SET_AMOUNT'
       items = items.where('amount IS NULL')
       items = items.where('execution_date IS NOT NULL')
       
   end #case

   #ordino per data     
   render json: items.limit(500).as_json(Activity.as_json_prop)     
   
 
 end 
   
 
 
##################################################
 def modify_record
##################################################
  @item = Activity.find(params[:rec_id])    
  @from_component_id = params[:from_grid_id]
 end   
   
##################################################
 def exe_modify_record
##################################################
  item = Activity.find(params[:data][:id])    
  params[:data].permit!
  item.update(params[:data])
  ret = item.save!  
  render json: {success: ret}
 end   
 
  
##################################################
 def exe_delete_activity
##################################################
  item = Activity.find(params[:rec_id])    
  ret = item.destroy!
  ret = true
  render json: {success: ret}
 end   
 
 
 
##################################################
 def report_parameters
##################################################
   @item = Activity.new
 end   
 
 def report_by_customer
 end
  
end
