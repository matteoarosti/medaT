# encoding: utf-8
class WeighsController < ApplicationController
  
  #Prenota pesata (terminal)
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
  

  #Prenota pesata (customer)
  def new_request_customer

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
     @item = Weigh.new  
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
     items = items.where("customer_id = ?", params[:form_user][:flt_customer_id]) if !params[:form_user][:flt_customer_id].to_s.empty?
     items = items.where("booking_customer LIKE ?", "%#{params[:form_user][:flt_booking_customer].upcase}%") if !params[:form_user][:flt_booking_customer].to_s.empty?
          
     case params[:filtered_type]           
       
       when 'TO_WEIGH'
         items = items.where('weigh_status = ?', 'OPEN')
         
         #aggiungo le reichiesta di pesa da handling_item (in base al flag sul booking)         
         #ToDo: parametrizzare
         terminal = Terminal.find(3) rescue terminal = nil #potrebbe andare in errore perche' l'utente corrente ha il filtro che esclude il terminal di sistema
         unless terminal.nil? 
           to_do_items = HandlingItem.joins(:handling_header).includes(:handling_header, :terminal).preload(:hh_booking).where('to_weigh = true')
           
           #applico filtri impostati da utente
           to_do_items = to_do_items.where("handling_headers.container_number LIKE ?", "%#{params[:form_user][:flt_num_container].upcase}%") if !params[:form_user][:flt_num_container].to_s.empty?
           to_do_items = to_do_items.where("driver LIKE ?", "%#{params[:form_user][:flt_driver].upcase}%") if !params[:form_user][:flt_driver].to_s.empty?
           to_do_items = to_do_items.where("plate LIKE ?", "%#{params[:form_user][:flt_plate].upcase}%") if !params[:form_user][:flt_plate].to_s.empty?
           ###to_do_items = to_do_items.where("plate_trailer LIKE ?", "%#{params[:form_user][:flt_plate_trailer].upcase}%") if !params[:form_user][:flt_plate_trailer].to_s.empty?       
           
           
           to_do_items = to_do_items.limit(100).each do |hi|
             
             #potrei non avere il booking (ad esempio su rientro da altro terminal)
             m_booking = hi.handling_header.booking
             to_weigh_in_terminal = !m_booking.nil? ? m_booking.to_weigh_in_terminal : false

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
               :to_weigh_in_terminal => to_weigh_in_terminal,
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
            }.reverse
         
      when 'LIST'
        items = items.where.not(weigh_status: 'DEL').order(created_at: :desc).limit(500)          
         
     end #case

     #ordino per data     
     render json: items.as_json(Weigh.as_json_prop)     
     
   
   end 
      
   
  #salvataggio dati di testata (autista, ...) 
  ##################################################
  def save_weigh_header_data
  ##################################################
    if (params[:type] == 'FROM_HI')         #inserimento pesa da movimento
      hi = HandlingItem.find(params[:rec_id])
      item = hi.weigh        
      if (!item)
        item = Weigh.new
      end  
    else
      item = Weigh.find(params[:rec_id])
    end
    
    item.driver = params[:driver]
    item.plate  = params[:plate]
    item.plate_trailer = params[:plate_trailer]
    if (params[:type] != 'FROM_HI')
      item.container_number  = params[:container_number] unless params[:container_number].nil?
      item.booking_customer  = params[:booking_customer] unless params[:booking_customer].nil?
    end
    ret = item.save!
    render json: {success: ret}
  end   
   
   
   #n
  ##################################################
   def generate_pdf
  ##################################################
     if (params[:type] == 'FROM_HI')         #inserimento pesa da movimento
       hi = HandlingItem.find(params[:rec_id])
       item = hi.weigh
       if (!item)         
           render json: {success: false, msg: 'Pesi mancanti'}
           return
       end
     else                                    #inserimento pesa da prenotazione
      item = Weigh.find(params[:rec_id]) 
     end
     
     
     #genero pdf
      tmp_file_name = Tempfile.new(['weigh_cedolino_', '.pdf']).path
      pdf = WeighCedolinoPdf.new()
      pdf.draw(item)
      pdf.render_file(tmp_file_name)      
      print "\nGenerato"
      item.scan_file = File.open(tmp_file_name)
      item.save!
      
     render json: {success: true, pesi: pdf.pesi}
   end
   
   
   
   
  ##################################################
   def save_weight
  ##################################################
    
    if (params[:type] == 'FROM_HI')         #inserimento pesa da movimento
      ActiveRecord::Base.transaction do   
       begin
                 
        hi = HandlingItem.find(params[:rec_id])
        
        item = hi.weigh        
        if (!item)
          item = Weigh.new
        end  
        
         item.external = params[:external]
         if (!params[:weight].blank?)  
          item.weight = params[:weight].to_s.gsub(',', '.').to_f
         else
           item.weight_container = params[:weight_container].to_s.gsub(',', '.').to_f
           item.weight_goods = params[:weight_goods].to_s.gsub(',', '.').to_f
           item.weight = item.weight_container + item.weight_goods
         end
        
        
        item.weigh_status = 'CLOSE'
        item.terminal_id = 3 #ToDo: parametrizzare
        item.shipowner_id = hi.handling_header.shipowner_id
        item.container_number = hi.handling_header.container_number 
        item.handling_item_id = params[:rec_id]
        
        #il file potrei averlo generato e non lo ricevo in fase di salvataggio
        if !params[:file].nil?  
          item.scan_file = params[:file]
        end
              
        item.weighed_at = Time.zone.now
        item.driver = params[:driver]
        item.plate  = params[:plate]
        item.plate_trailer = params[:plate_trailer]
        ret = item.save!        
        item.send_mail_html_to_customer
        
         #settaggio su handling_item
         hi.to_weigh = false
         hi.weigh_id = item.id
         hi.save!
         
         #riporto il peso su hh
         hi.handling_header.weight_exp = item.weight
         hi.handling_header.save!
        
        render json: {success: true, w_id: item.id}
      rescue => exception
        to_rollback = true  
        logger.info exception.backtrace
        render json: {:success => false, :message => 'Errore sconosciuto. Contattare amministratore di sistema'}     
      end
      raise ActiveRecord::Rollback if to_rollback    
     end #transaction      
    else                                    #inserimento pesa da prenotazione
      item = Weigh.find(params[:rec_id])
        
       item.external = params[:external]
       if (!params[:weight].blank?)  
        item.weight = params[:weight].to_s.gsub(',', '.').to_f
       else
         item.weight_container = params[:weight_container].to_s.gsub(',', '.').to_f
         item.weight_goods = params[:weight_goods].to_s.gsub(',', '.').to_f
         item.weight = item.weight_container + item.weight_goods
       end        
        
      item.weigh_status = 'CLOSE'
     
      #il file potrei averlo generato e non lo ricevo in fase di salvataggio
      if !params[:file].nil?  
        item.scan_file = params[:file]
      end
         
      item.weighed_at = Time.zone.now
      item.driver = params[:driver]
      item.plate  = params[:plate]
      item.plate_trailer = params[:plate_trailer]       
        
      
      item.container_number  = params[:container_number] unless params[:container_number].nil?
      item.booking_customer  = params[:booking_customer] unless params[:booking_customer].nil?
        
      ret = item.save!
      item.send_mail_html_to_customer  
      render json: {success: ret, w_id: item.id}
    end 
   end   

   
   #annullo la richiesta di peso
   ##################################################
   def delete_weight_ric
   ##################################################
  
    if (params[:type] == 'FROM_HI')         #inserimento pesa da movimento
      hi = HandlingItem.find(params[:rec_id])
      hi.to_weigh = false
      hi.save!
    else                                    #inserimento pesa da prenotazione
      item = Weigh.find(params[:rec_id])
      item.weigh_status = 'DEL'
      ret = item.save! 
    end
    render json: {success: true}
   end
   
   

  ##################################################
   def view_scan_file
  ##################################################
     if (params[:type] == 'FROM_HI')    
       hi = HandlingItem.find(params[:rec_id])
       @item = hi.weigh     
     else
       @item = Weigh.find(params[:rec_id])       
     end
   end   

  ##################################################
   def download_file
  ##################################################
    @item = Weigh.find(params[:id])
     send_file @item.scan_file.path('original'),
                 :type => @item.scan_file_content_type  
      
   end   

   
##################################################
 def modify_record
##################################################
  @item = Weigh.find(params[:rec_id])    
  @from_component_id = params[:from_grid_id]
 end   
   
##################################################
 def exe_modify_record
##################################################
  item = Weigh.find(params[:data][:id])    
  params[:data].permit!
  item.update(params[:data])
  ret = item.save!  
  render json: {success: ret}
 end   


 
##################################################
 def modify_image
##################################################
  @item = Weigh.find(params[:rec_id])    
  @from_component_id = params[:from_grid_id]
 end   
   
##################################################
 def exe_modify_image
##################################################
  item = Weigh.find(params[:id])    
  item.scan_file = params[:file]
  ret = item.save!  
  render json: {success: ret}
 end   

##################################################
 def export_open_params
##################################################
  @item = Weigh.new    
 end       
 

##################################################
 def export_exe
##################################################
   formValues = JSON.parse params['formValues']
   items = Weigh.where('weigh_status = ?', 'CLOSE')
   
   #gestione campi data/ora
   if !formValues['weighed_at_from'].blank?
     datetime_from = Time.zone.parse(formValues['weighed_at_from'] + ' ' + (formValues['weighed_at_from_time'] || '00:00') + ':00')
   end
   
   if !formValues['weighed_at_to'].blank?
     datetime_to = Time.zone.parse(formValues['weighed_at_to'] + ' ' + (formValues['weighed_at_to_time'] || '23:59') + ':59')
   end
   
   items = items.where("weighed_at >= ?", datetime_from) unless datetime_from.nil?
   items = items.where("weighed_at <= ?", datetime_to) unless datetime_to.nil?
   items = items.where("terminal_id = ?", formValues['terminal_id']) unless formValues['terminal_id'].blank?
   items = items.where("customer_id = ?", formValues['customer_id']) unless formValues['customer_id'].blank?
     
   items = items.joins(" LEFT OUTER JOIN users      ON weighs.created_user_id = users.id")     
   items = items.joins(" LEFT OUTER JOIN terminals  ON terminal_id = terminals.id")
   items = items.joins(" LEFT OUTER JOIN customers  ON customer_id = customers.id")
   items = items.select('weighs.*, terminals.code as terminal_code, customers.name as customer_name, users.name as created_by_name')  
   
   tmp_file = Tempfile.new(['medaT_weighs_export', '.xls'])
   File.open(tmp_file, "wb") do |f|
     f.write(
       items.to_xls(
         :columns => [:created_by_name, :terminal_code, :container_number, :customer_name, :booking_customer, :weighed_at, :weight, :external, :driver, :plate, :plate_trailer],
         :headers => ["Richiedente", "Terminal", "Container", "Cliente", "Booking Cliente", "Data/ora pesata", "Peso", "Pesata esterna", "Autista", "Targa", "Targa rimorchio"]
       )
     )
   end    
   send_file(tmp_file)
   return
 end       
 
 
 
 def search_in_medaT
   #cerco eventuale movimento aperto per container
   @item = HandlingHeader.not_closed.container(params[:form_values][:medaT_search_num_container]).first
 end
 
 
 
 
 
 #lista eventi su weigh
 def get_weigh_events
   if (params[:type] == 'FROM_HI')    
     hi = HandlingItem.find(params[:rec_id])
     item = hi.weigh
     if !item
       render json: []
       return
     end     
   else
     item = Weigh.find(params[:rec_id])       
   end
     
   items = LogEvent.all_for(item)
   ret = []
   peso_lordo = 0
   peso_tara  = 0
   items.each do |i|
     
     jp = (ActiveSupport::JSON.decode i.notes).with_indifferent_access
     
     r = {}
     case i.operation
       when 'LORDO'
         r[:out_des] = '<h3>PESO LORDO</h3>'
         peso_lordo = jp[:weigh]
       when 'TARA'
         r[:out_des] = '<h3>TARA</h3>'
         peso_tara  = jp[:weigh]
     end
     
     #utente/data
     u = User.find(i.created_user_id) rescue u = nil
     r[:out_des] += u.name if !u.nil?
     r[:out_des] += ", " + i.created_at.strftime("%d/%m/%y %H:%M")
       
     #peso          
     r[:out_des] += ", " + jp[:weigh].to_s + "Kg"
       
     ret << r    
   end
   
   #se ho peso lordo e tara propongo il totale
   if (peso_lordo > 0 && peso_tara > 0)
     
     font_color = 'green'
     font_color = 'red' if (peso_lordo - peso_tara) < 0       
     
     ret << {out_des: "<FONT color=#{font_color}><h3>Netto: " + (peso_lordo - peso_tara).to_s + '</h3></font>'}
   end
   
   render json: ret.as_json            
 end
 
 
 
 #registro evento (peso lordo o tara)
 def exe_save_weigh_event
   if (params[:type] == 'FROM_HI')         #inserimento pesa da movimento
      hi = HandlingItem.find(params[:rec_id])
      if hi.weigh_id
        item = hi.weigh
      else
       
        #creo intanto weigh per hi, se non esiste gia
        item = Weigh.new
        item.handling_item_id = hi.id        
        item.save!
        hi.weigh_id = item.id
        hi.save!
      end 
   else                                    #inserimento pesa da prenotazione
     item = Weigh.find(params[:rec_id])         
   end

   if params[:peso].to_i > 0
     peso_letto = params[:peso].to_i
   else      
     peso_letto = 0   
     #leggo peso da pesa (scheda LAN)
     localhost = Net::Telnet::new("Host" => "192.168.201.10",
                                  "Timeout" => 10,
                                  "Prompt" => /[$%#>] \z/n)
     localhost.cmd("R") { |c| 
        #ricevo es: ST,GS,       0,kg
        #ToDo: memorizzare anche UM
        ar_lettura = c.split(',')
        peso_letto = ar_lettura[2]  
     }
     localhost.close  
   
     #per test 
     peso_letto = 800
   end

   #sull'item registro l'evento
   LogEvent.base(item, 'H', params[:tipo_evento], {weigh: peso_letto})
   render json: {success: true}
   
 end #exe_save_weigh_event
   
end
