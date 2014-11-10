class TerminalMovsController < ApplicationController

  layout "application_extjs", only: [:index]
  

  def index
  end
  
  
  #EXTJS SCAFFOLD
  def sc_crt_tab_PORTI_DELETEEEEE
    @sc_columns = []  
    Porto.columns.map {|c| @sc_columns << sc_crt_column(c)}
    render :partial=>"sc_crt_tab", :locals=>{:sc_columns => @sc_columns, :sc_store => sc_crt_store()}            
  end
  


##########################################
 def sc_list_DELETEEEEEEE
########################################## 

  0.times do |i|
   n = Porto.new
    n.denominazione = i
   n.save
  end
 
  ret = {}
  ret[:items] = Porto.limit(params[:limit]).offset(params[:start])
  ret[:total] = Porto.count
  render json: ret
 end  

########################################## 
 def sc_update_DELETEEEEEEE
########################################## 
  item = Porto.find(params[:data][:id])
  params[:data].permit!
  item.update(params[:data])
  item.save()
  render json: {:success => true, :data=>item}
 end 
 
  
end
