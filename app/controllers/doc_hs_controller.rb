class DocHsController < ApplicationController
  
  def w_list
  end
  
  def get_list
    items = DocH.all
    items = items.where(doc_type_id: params[:o_filter][:doc_type_id])
      
    items = items.where("created_at >= ?", Time.zone.parse(params[:form_user]['flt_date_from']).beginning_of_day) unless params[:form_user]['flt_date_from'].blank?
    items = items.where("created_at <= ?", Time.zone.parse(params[:form_user]['flt_date_to']).end_of_day) unless params[:form_user]['flt_date_to'].blank?
    items = items.where(:customer_id => params[:form_user]['flt_customer_id']) unless params[:form_user]['flt_customer_id'].blank?  
       
      
    items = items.order('id desc')  
      
    render json: items.limit(100).as_json(DocH.as_json_prop)     
  end
  
  
  
  ##################################################
   def view_scan_file
  ##################################################
    @item = DocH.find(params[:rec_id])
   end  
  ##################################################
   def download_file
  ##################################################
    @item = DocH.find(params[:id])
     send_file @item.doc_file.path('original'),
                 :type => @item.doc_file_content_type,
                 :x_sendfile => true,
                 :disposition => 'inline'
      
   end  
  
end
