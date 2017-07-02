class ShipPreparesController < ApplicationController
  
  layout "application_report", only: [:report_by_customer]
  
  def create_new
    @item = ShipPrepare.new
  end
  
  def create_new_exe
    item = ShipPrepare.new
    params[:data].permit!
    item.update(params[:data])
    item.save!()
    render json: {:success => true, :data=>[item.as_json(ShipPrepare.as_json_prop)]}    
  end
  

  def set_execution
    item = ShipPrepare.find(params[:data][:id])
    params[:data].permit!
    item.update(params[:data])
    item.execution_date = Time.zone.now if item.execution_date.nil?
    item.execution_at   = Time.zone.now
    item.execution_user_id = current_user.id
    item.save!()
    render json: {:success => true, :data=>[item.as_json(ShipPrepare.as_json_prop)]}    
  end
  
  def set_amount
    item = ShipPrepare.find(params[:data][:id])
    params[:data].permit!
    item.update(params[:data])
    item.save!()
    render json: {:success => true, :data=>[item.as_json(ShipPrepare.as_json_prop)]}    
  end
    
  
  def gest
    @item = ShipPrepare.find(params[:item_id])
  end

  def select_import_header
    @item = ShipPrepare.find(params[:item_id])
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
   
   items = ShipPrepare.all #.where('repair_status=?', 'OPEN')
   
   #applico filtri impostati da utente
#   items = items.where("container_number LIKE ?", "%#{params[:form_user][:flt_num_container].upcase}%") if !params[:form_user][:flt_num_container].to_s.empty?
        

   params[:form_user] = {} if params[:form_user].nil?
   items = items.where("created_at >= ?", Time.zone.parse(params[:form_user]['flt_date_from']).beginning_of_day) unless params[:form_user]['flt_date_from'].blank?
   items = items.where("created_at <= ?", Time.zone.parse(params[:form_user]['flt_date_to']).end_of_day) unless params[:form_user]['flt_date_to'].blank?
   
   case params[:filtered_type]           
     
     when 'OPEN'
       items = items.not_closed

     when 'SET_AMOUNT'
       items = items.where('amount IS NULL')
       items = items.not_closed
       
   end #case

   #ordino per data     
   render json: items.limit(500).as_json(ShipPrepare.as_json_prop)     
   
 
 end 
   
 
 
##################################################
 def get_open_voyage_by_ship
##################################################
  ret = {}
  ret[:success] = true   
  @sp = ShipPrepare.find(params[:id])    
  ret[:items] = ImportHeader.where("ship_id = ?", @sp.ship_id).where("import_status = ?", 'OPEN').as_json(ImportHeader.as_json_prop)
  render json: ret
 end   
 
 
 
##################################################
 def modify_record
##################################################
  @item = ShipPrepare.find(params[:rec_id])    
  @from_component_id = params[:from_grid_id]
 end   
   
##################################################
 def exe_modify_record
##################################################
  item = ShipPrepare.find(params[:data][:id])    
  params[:data].permit!
  item.update(params[:data])
  ret = item.save!  
  render json: {success: ret}
 end   
 
  
##################################################
 def exe_delete_record
##################################################
  item = ShipPrepare.find(params[:rec_id])    
  ret = item.destroy!
  ret = true
  render json: {success: ret}
 end   
 
 
 
##################################################
 def report_parameters
##################################################
   @item = ShipPrepare.new
 end   

 
 
##################################################
 def get_gest_items
##################################################
   @sp = ShipPrepare.find(params[:item_id])
   ret = {}
   ret[:success] = true
   ret[:items] = @sp.ship_prepare_items.as_json(ShipPrepareItem.as_json_prop)
   render json: ret

  
 end   
  
 
##################################################
 def add_item_row
##################################################
   @sp = ShipPrepare.find(params[:data][:item_id])
   item = @sp.ship_prepare_items.new
   params[:data].delete(:item_id)
   params[:data].permit!
   item.update(params[:data])

   item.in_out_type = item.import_header.import_type if item.item_type == 'LS'     
     
   ret = item.save!  
   
   render json: {success: ret}  
 end   
 
 
 
 
 
##################################################
 def modify_record_item
##################################################
  @item = ShipPrepareItem.find(params[:rec_id])    
  @from_component_id = params[:from_grid_id]
 end   

 
##################################################
 def exe_modify_item_record
##################################################
  item = ShipPrepareItem.find(params[:data][:id])    
  params[:data].permit!
  item.update(params[:data])
  ret = item.save!  
  render json: {success: ret}
 end   

##################################################
 def exe_delete_item_record
##################################################
   item = ShipPrepareItem.find(params[:rec_id])    
   ret = item.destroy!
   ret = true
   render json: {success: ret}
 end   
 
#azzero il flag to_be_moved (eseguito dal mulettista dopo aver movimentato il container)
##################################################
def items_close_to_be_moved
##################################################
  hi = ShipPrepareItem.find(params[:rec_id])
  hi.moved_by_user_id = current_user.id
  hi.moved_at = Time.zone.now
  hi.save!
  render json: {:success => true, :message => nil}      
end
 
#aggiungo le quantita imbarco / sbarco
##################################################
def save_item_weight
##################################################
  spi = ShipPrepareItem.find(params[:rec_id])
  item = spi.ship_prepare_item_weighs.new
  params.permit!
    
  item.qty = params[:qty].to_s.gsub(',', '.').to_f
  item.qty_tare = params[:qty_tare].to_s.gsub(',', '.').to_f
  item.qty_gross = params[:qty_gross].to_s.gsub(',', '.').to_f
  item.plate = params[:plate]  
    
  ret = item.save!  
  render json: {:success => true, :message => nil}      
end
 

#aggiungo le quantita di ricarica
##################################################
def save_item_weight_ric
##################################################
  spi = ShipPrepareItem.find(params[:rec_id])
  item = spi.ship_prepare_item_weighs.new
  params.permit!
    
  item.qty_ric = params[:qty].to_s.gsub(',', '.').to_f
  item.qty_tare = params[:qty_tare].to_s.gsub(',', '.').to_f
  item.qty_gross = params[:qty_gross].to_s.gsub(',', '.').to_f    
  item.plate = params[:plate]  
    
  ret = item.save!  
  render json: {:success => true, :message => nil}      
end
 

 def get_item_weight_details
   spi = ShipPrepareItem.find(params[:rec_id])
   ret = {}
   ret[:success] = true     
   if (params[:type] == 'RIC')
    ret[:items] = spi.ship_prepare_item_weighs.ric.as_json(ShipPrepareItemWeigh.as_json_prop)
   else
     ret[:items] = spi.ship_prepare_item_weighs.not_ric.as_json(ShipPrepareItemWeigh.as_json_prop)
   end 
   render json: ret
 end
 
 def edit_item_weight_details
  @item = ShipPrepareItemWeigh.find(params[:id])
 end
 
 def exe_edit_item_weight_details
   item = ShipPrepareItemWeigh.find(params[:data][:id])
   params.permit!
   item.update(params[:data])
   ret = item.save!  
   render json: {success: ret}
 end

def exe_delete_item_weight_details
  item = ShipPrepareItemWeigh.find(params[:data][:id])
  ret = item.destroy!  
  render json: {success: ret}
end


 # Report rendiconto singola lavoazione  
 def r_rendiconto_parameters
   @item = ShipPrepareItem.find(params[:rec_id])
 end
 def r_rendiconto_a
 end
 
 
  
  
end
