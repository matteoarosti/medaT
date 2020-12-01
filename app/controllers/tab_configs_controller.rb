class TabConfigsController < ApplicationController

    
 def extjs_sc_model
  'TabConfig'
 end 

 ##################################################
  def attach_file_updload_exe
 ##################################################
   item = TabConfig.find(params[:rec_id])
   item.attach_file = params[:file]
   ret = item.save!
   render json: {success: ret, item_id: item.id}  
  end 
  
  
##################################################
 def view_attach_file
##################################################
  @item = TabConfig.find(params[:rec_id])
 end 

  def download_file
   @item = TabConfig.find(params[:id])
    send_file @item.attach_file.path('original'),
                :type => @item.attach_file_content_type  
     
  end 

  
##################################################
 def attach_file_remove_exe
##################################################
  item = TabConfig.find(params[:rec_id])
  item.attach_file = nil
  ret = item.save!
  render json: {success: ret, item_id: item.id}  
 end 
  
   
end
