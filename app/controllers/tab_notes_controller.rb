class TabNotesController < ApplicationController
    
 def extjs_sc_model
  'TabNote'
 end 
  
 
 def attach_file_updload_exe
   item = TabNote.new
   item.container_number = params[:container_number] if params[:container_number]
   item.rsc_type = params[:rsc_type] if params[:rsc_type]
   item.rsc_id   = params[:rsc_id]   if params[:rsc_id]     
   item.attach_file = params[:file]
   ret = item.save!
   render json: {success: ret, item_id: item.id}    
 end
 
 
 
 def get_list_data
   items = TabNote.all
   if params[:tab_note]
    items = items.where(container_number: params[:container_number]) if params[:tab_note][:container_number]
   end      
   items = items.order(:id) 
   render json: items.as_json(TabNote.as_json_prop)  
 end
 
 
 
##################################################
 def download_file
##################################################
  @item = TabNote.find(params[:id])
   send_file @item.attach_file.path('original'),
               :type => @item.attach_file_content_type,
               :x_sendfile => true,
               :disposition => 'inline'
 end
 
   
end

