class WeighsController < ApplicationController
  
  #Prenota pesata
  def new_request

    @item = Weigh.new
    @item.weigh_status = 'OPEN'        
    
    #Inserimento record in ToDoItem
    if params[:exe_save] == 'Y'    
      
      unless params[:no_CD] == 'Y'
        valid_CD = ImportHeader.check_digit(params[:container_number])
        if valid_CD == -501
          render json: {:success => false, :message => 'Errore nel numero container'}
          return false
        end
      end  
      
        
      to_save_params = params.select{|k,v| Weigh.column_names.include?(k) && k != 'id'}  
      to_save_params.permit!
      @item.update(to_save_params)
      
      #se sono qui procedo al salvataggio
      r = @item.save  
      
      if r
        message = 'Salvataggio esequito'
      else
        message = 'Errore in fase di salvataggio'
      end
      
      render json: {:success => r, :message => message}
      return
    end
    
  end
  
  
  
  ##################################################
   def weighs_list
  ##################################################  
     render :partial=>"weighs_list", :locals => {:filtered_type => params[:filtered_type] }
   end

  ##################################################
   def get_row_by_filtered_type
  ##################################################
     
     items = Weigh.all #.where('repair_status=?', 'OPEN')
     
     #applico filtri impostati da utente
     items = items.where("container_number LIKE ?", "%#{params[:form_user][:flt_num_container].upcase}%") if !params[:form_user][:flt_num_container].to_s.empty?
     items = items.where("driver LIKE ?", "%#{params[:form_user][:flt_driver].upcase}%") if !params[:form_user][:flt_driver].to_s.empty?
     items = items.where("plate LIKE ?", "%#{params[:form_user][:flt_plate].upcase}%") if !params[:form_user][:flt_plate].to_s.empty?
     items = items.where("plate_trailer LIKE ?", "%#{params[:form_user][:flt_plate_trailer].upcase}%") if !params[:form_user][:flt_plate_trailer].to_s.empty?       
          
     case params[:filtered_type]           
       
       when 'TO_WEIGH'
         items = items.where('weigh_status = ?', 'OPEN')
         
         #aggiungo i pese da handling_item         
         #ToDo: parametrizzare
         terminal = Terminal.find(3) rescue terminal = nil #potrebbe andare in errore perche' l'utente corrente ha il filtro che esclude il terminal di sistema
         unless terminal.nil? 
           to_do_items = HandlingItem.joins(:handling_header).where('to_weigh = true')
           
           #applico filtri impostati da utente
           to_do_items = to_do_items.where("handling_headers.container_number LIKE ?", "%#{params[:form_user][:flt_num_container].upcase}%") if !params[:form_user][:flt_num_container].to_s.empty?
           to_do_items = to_do_items.where("driver LIKE ?", "%#{params[:form_user][:flt_driver].upcase}%") if !params[:form_user][:flt_driver].to_s.empty?
           to_do_items = to_do_items.where("plate LIKE ?", "%#{params[:form_user][:flt_plate].upcase}%") if !params[:form_user][:flt_plate].to_s.empty?
           ###to_do_items = to_do_items.where("plate_trailer LIKE ?", "%#{params[:form_user][:flt_plate_trailer].upcase}%") if !params[:form_user][:flt_plate_trailer].to_s.empty?       
           
           
           to_do_items = to_do_items.limit(1000).each do |hi|

             items << {
               :type => 'FROM_HI',             
               :id => hi.id, #attenzione: se ho lo stesso id di weigh potrebbe non essere visualizzato
               :terminal_id => terminal.id, 
               :container_number => hi.handling_header.container_number,
               :handling_item_id => hi.id,
               :driver => hi.driver,
               :plate  => hi.plate,
               :plate_trailer => '', #ToDo
               :created_at => hi.created_at,
               :terminal => {
                  :id => terminal.id,
                  :code => terminal.code,
                  :name => terminal.name
               }
             }       
           end
         end
         
       items = items.sort_by{|a|
              if a.is_a? Hash
                a[:created_at]         
              else
                a.created_at
              end 
            }
         
      when 'LIST'
        items = items.order(created_at: :desc).limit(500)          
         
     end #case

     #ordino per data     
     render json: items.as_json(Weigh.as_json_prop)     
     
   
   end 
      
   
  ##################################################
   def save_weight
  ##################################################
    
    if (params[:type] == 'FROM_HI')         #inserimento pesa da movimento
      ActiveRecord::Base.transaction do   
       begin
                 
        hi = HandlingItem.find(params[:rec_id])
         
        item = Weigh.new
        item.weigh_status = 'CLOSE'
        item.terminal_id = 3 #ToDo: parametrizzare
        item.container_number = hi.handling_header.container_number 
        item.handling_item_id = params[:rec_id]
        item.weight = params[:weight].to_s.gsub(',', '.').to_f
        item.scan_file = params[:file]
        item.weighed_at = Time.zone.now
        item.driver = params[:driver]
        item.plate  = params[:plate]
        item.plate_trailer = params[:plate_trailer]
        ret = item.save!
        
         #settaggio su handling_item
         hi.to_weigh = false
         hi.weigh_id = item.id
         hi.save!
        
        render json: {success: true}
      rescue => exception
        to_rollback = true  
        logger.info exception.backtrace
        render json: {:success => false, :message => 'Errore sconosciuto. Contattare amministratore di sistema'}     
      end
      raise ActiveRecord::Rollback if to_rollback    
     end #transaction      
    else                                    #inserimento pesa da prenotazione
      item = Weigh.find(params[:rec_id])
      item.weigh_status = 'CLOSE'
      item.weight = params[:weight].to_s.gsub(',', '.').to_f
      item.scan_file = params[:file]
      item.weighed_at = Time.zone.now
      item.driver = params[:driver]
      item.plate  = params[:plate]
      item.plate_trailer = params[:plate_trailer]
      
      ret = item.save!  
      render json: {success: ret}        
    end 
   end   


  ##################################################
   def view_scan_file
  ##################################################
    @item = Weigh.find(params[:rec_id])
   end   

  ##################################################
   def download_file
  ##################################################
    @item = Weigh.find(params[:id])
     send_file @item.scan_file.path('original'),
                 :type => @item.scan_file_content_type  
      
   end   
  
   
end
