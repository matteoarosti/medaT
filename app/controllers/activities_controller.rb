class ActivitiesController < ApplicationController
  
  layout "application_report", only: [:report_by_customer, :report_by_customer_s]
  
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
    #params[:data].permit!
    #item.update(params[:data])
    
    #se ho la gestione per dettaglio (cust_inpsect) aggiorno il prezzo acnhe sulle righe, oltre il totale
    if !params[:data][:containers_dett_amount].nil?
      params[:data][:containers_dett_amount].each do |p|
        d = ActivityDettContainer.find(p[:id])
        d.op_amount = p[:op_amount]
        d.save!
      end
    end
      
    item.amount = params[:data][:amount]
    item.save!()
    render json: {:success => true, :data=>[item.as_json(Activity.as_json_prop)]}    
  end
    
  def set_amount2
    render json: {success: true}
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
   items = items.where(:customer_id => params[:form_user]['flt_customer_id']) unless params[:form_user]['flt_customer_id'].blank?  
   
   case params[:filtered_type]           
     
     when 'OPEN'
       items = items.where('execution_date IS NULL')

     when 'SET_AMOUNT'
       items = items.where('amount IS NULL')
       items = items.where('execution_date IS NOT NULL')
       
     when 'ALL'  
       items = items.order('id desc')
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
 def exe_set_default_price
##################################################
  item = Activity.find(params[:rec_id])    
  if item.activity_op.default_price.nil?
    render json: {success: false}
  end
  #se sono qui... sto impostando il prezzo di default
  item.amount = item.activity_op.default_price    
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
 def report_by_customer_s
 end

 
################################################## 
#tab dashboard
##################################################
  def tab_dashboard
    render :partial => "tab_dashboard"
  end

  def tab_dashboard_movs_by_date
    ret = {}
    ret[:items] = []
    r = {'C' => {}, 'S' => {}}
    
    #raggruppo i movimenti aperti in base al lock
     gcs = Activity.select('execution_date as date_op, count(*) as t_cont, sum(amount) as s_amount').group('execution_date')
     gcs = gcs.order('execution_date DESC').limit(60)
     gcs.each do |gc|
         r["C"]["#{gc.date_op}"] = r["C"]["#{gc.date_op}"].to_i + gc.t_cont.to_f;
         r["S"]["#{gc.date_op}"] = r["S"]["#{gc.date_op}"].to_i + gc.s_amount.to_f;
     end  
     
    #scorro gli ultimi 60 giorni
     sd = Time.now - 60.days
     ed = Time.now
     
     tmp  = sd
     begin
       s = {}
       s[:op] = tmp.to_date
       s[:C] = r["C"]["#{tmp.to_date}"] || 0
       s[:S] = r["S"]["#{tmp.to_date}"] || 0
       ret[:items] << s
       tmp += 1.day
     end while tmp <= ed 
  
    render json: ret
  end
  
  
  
##################################################
 def view_scan_file
##################################################
  @item = Activity.find(params[:rec_id])
 end  
##################################################
 def download_file
##################################################
  @item = Activity.find(params[:id])
   send_file @item.scan_file.path('original'),
               :type => @item.scan_file_content_type,
               :x_sendfile => true,
               :disposition => 'inline'
    
 end   

 
   
   
end
