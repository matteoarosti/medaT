class TerminalMovsController < ApplicationController

  layout "application_extjs", only: [:index, :index_mulettista]
  

#ingresso (apertura viewport Extjs)
  def index
    if User.current.admin?
      ##redirect_to :controller => 'terminal_movs', :action => 'ddddd'
      #pagina standard (show)
      return
    end
    
    if User.current.mulettista?
      render "index_mulettista"
      return
    end
    
    if User.current.agenzia?
      render "index_agenzia"
      return
    end    

    
    if User.current.officina?
      render "index_officina"
      return
    end    

    if User.current.terminal?
      render "index_terminal"
      return
    end    
    
    
    #se sono qui: role non definito
    render "index_not_defined"
  end


#verifico validita' numero container, mostro elenco movimento o voce per crearne uno nuovo
#############################################################
def new_mov_search_handling
#############################################################
 ret = {}
 ret[:items] = []
 
  params[:container_number] = params[:search_number] if params[:search_type] == 'container'
  params[:booking_number]   = params[:search_number] if params[:search_type] == 'booking'  
 
  hhs = HandlingHeader.where('1 = 1')
  hhs = hhs.where('container_number LIKE ?', "%#{params[:container_number]}%") unless params[:container_number].blank?
  hhs = hhs.where('num_booking LIKE ?', "%#{params[:booking_number]}%") unless params[:booking_number].blank?
  if !params[:status].blank?
    if params[:status] == 'CLOSE' 
      hhs = hhs.where('handling_status = ?', 'CLOSE')
    else
      hhs = hhs.where('handling_status <> ?', 'CLOSE')
    end
  end
 
  hhs = hhs.limit(100)
 
 handling_EDIT_exists = false
 
  hhs.each do |hh|
    if hh.handling_status == 'CLOSE'
     op = 'VIEW'
     op_descr = '[ Visualizza ]'
    else
     handling_EDIT_exists = true    
     op = 'EDIT' 
     op_descr = '[ Modifica ]'
    end
     
    ret[:items] << {
        :handling_id  => hh.id, :num_booking  => hh.num_booking,
        :container_number => hh.container_number, :is_container_editable => false,
        :stato => hh.handling_status, :stato_descr => hh.handling_status, :op => op, :op_descr => op_descr,
        :lock_fl => hh.lock_fl, :lock_type =>hh.lock_type,
        #:descr => "##{hh.id.to_s}, #{HandlingHeader::TYPES[hh.handling_type]}",
        :descr => ["##{hh.id.to_s}", I18n.t("handling_type.#{hh.handling_type}.short")].join(', '),      
        :equipment_id_Name => (hh.equipment.send(Equipment.combo_displayField) unless hh.equipment.nil?) ,
        :shipowner_id_Name => hh.shipowner.send(Shipowner.combo_displayField),
        :num_booking => hh.num_booking,
        :container_FE => hh.container_FE,
        :container_in_terminal => hh.container_in_terminal,
        :updated_at => hh.updated_at
      }
  end
 
  
  if User.current.can?(:handling_header, :create)
     #se non ci sono movimenti aperti, ne propongo uno nuovo (se cercavo per num container)
     if ret[:items].length > 0 && !handling_EDIT_exists && !params[:container_number].blank? && params[:status]!='CLOSE'
      ret[:items] << {:container_number => params[:container_number], :is_container_editable => false,
            :stato => 'CRT', :stato_descr => '', :descr => 'Crea nuovo movimento', :op => 'CRT', :op_descr => '[ Crea ]'} 
     end
     
     
     #se non ci sono movimenti aperti, ne propongo uno nuovo con possibilita' di creare container
     if ret[:items].length == 0  && !params[:container_number].blank? && params[:status]!='CLOSE'
      #verifico il check digiti
      valid_CD = ImportHeader.check_digit(params[:container_number])
      
      ret[:items] << {:container_number => params[:container_number], :is_container_editable => true, :valid_CD => valid_CD,
            :stato => 'CRT', :stato_descr => '', :descr => 'Crea nuovo', :op => 'CRT', :op_descr => '[ Crea ]'}
     end
  end
 
 
 render json: ret
end


  
# scelta tipo operazione per nuovo inserimento  
#############################################################
def add_handling_items_select_type
#############################################################
 @rec_id = params[:rec_id]
 hh = HandlingHeader.find(@rec_id)
 @operations = hh.get_operations('FOR_SELECT')  #elenco operazioni ammesse (per tipo, stato, ...)
end

  
#inserimento nuovo dettaglio movimento
#############################################################
def add_handling_items
#############################################################
 @rec_id = params[:rec_id]
 @op     = params[:op]
 @hh     = HandlingHeader.find(@rec_id)
 @new_rec = @hh.handling_items.new()
 @new_rec.handling_item_type = @op
 @new_rec.datetime_op = Time.now
 render :partial => "add_handling_items_" + @op
end  
  

  #tab dashboard
    def tab_dashboard
      render :partial => "tab_dashboard"
    end
    
    ####
    def tab_dashboard_open_movs_get_data
      ret = {}
      ret[:items] = []
      
      #raggruppo i movimenti aperti in base al lock
       gcs = HandlingHeader.select('handling_type, lock_type, count(*) as t_cont').where('handling_status=?', 'OPEN').group('handling_type, lock_type')
       gcs.each do |gc|
         n = gc.lock_type || 'ATTIVI'
         ret[:items] << {:os => [gc.handling_type, n].join(', ') + " (#{gc.t_cont.to_i.to_s})", :data1 => gc.t_cont}
       end   
        
      #ret[:items] << {:os => 'open', :data1 => 30}

      render json: ret
    end


    
    ####
    def tab_dashboard_in_out_get_data
      ret = {}
      ret[:items] = []
      
      #raggruppo i movimenti aperti
       gcs = HandlingHeader.select('container_in_terminal, container_FE, IF(ISNULL(booking_id), 0, 1) as with_b, count(*) as t_cont').where('handling_status=?', 'OPEN').by_type('TMOV').group('container_in_terminal, container_FE, IF(ISNULL(booking_id), TRUE, FALSE)')
       gcs.each do |gc|
         n = gc.container_in_terminal == true ? '[In]' : '[Out]'
         n += gc.container_FE == 'F' ? ' Pieno' : ' Vuoto'
         n += gc.with_b == 1 ? ' [b]' : ' '
         ret[:items] << {:os => n + " (#{gc.t_cont.to_i.to_s})", :data1 => gc.t_cont}
       end   
        
      #ret[:items] << {:os => 'open', :data1 => 30}
  
      render json: ret
    end
    

  ####
  def tab_dashboard_shipowner_get_data
    ret = {}
    ret[:items] = []
    
    #raggruppo i movimenti aperti in base al lock
     gcs = HandlingHeader.select('shipowner_id, count(*) as t_cont').where('handling_status=?', 'OPEN').group('shipowner_id')
     gcs.each do |gc|
       n = gc.shipowner_id_Name
       ret[:items] << {:os => n + " (#{gc.t_cont.to_i.to_s})", :data1 => gc.t_cont}
     end   
      
    #ret[:items] << {:os => 'open', :data1 => 30}

    render json: ret
  end
    

  
  
  ####
  def tab_dashboard_movs_by_date
    ret = {}
    ret[:items] = []
    r = {'I' => {}, 'O' => {}, 'L' => {}, 'D' => {}}
    
    #raggruppo i movimenti aperti in base al lock
     gcs = HandlingItem.select('DATE(datetime_op) as date_op, handling_items.handling_type, handling_item_type, count(*) as t_cont').where('operation_type=?', 'MT').group('DATE(datetime_op), handling_items.handling_type, handling_item_type')
     ### rallenta troppo e non serve!   gcs = gcs.joins(:handling_header)
     ###gcs = gcs.where('DATE(datetime_op) > NOW() - INTERVAL 35 DAY')
     gcs = gcs.order('DATE(datetime_op) DESC').limit(200)
     gcs.each do |gc|       
       if gc.handling_item_type == 'O_LOAD'
         r["L"]["#{gc.date_op}"] = r["L"]["#{gc.date_op}"].to_i + gc.t_cont;
       elsif gc.handling_item_type == 'I_DISCHARGE'
         r["D"]["#{gc.date_op}"] = r["D"]["#{gc.date_op}"].to_i + gc.t_cont;
       else
        r["#{gc.handling_type}"]["#{gc.date_op}"] = r["#{gc.handling_type}"]["#{gc.date_op}"].to_i + gc.t_cont;
       end
     end
 
    #ret[:items] << {:os => 'open', :data1 => 30}
     
    #scorro gli ultimi 30 giorni
     sd = Time.now - 30.days
     ed = Time.now
     
     tmp  = sd
     begin
       s = {}
       s[:op] = tmp.to_date
       s[:I] = r["I"]["#{tmp.to_date}"] || 0
       s[:O] = r["O"]["#{tmp.to_date}"] || 0
       s[:L] = r["L"]["#{tmp.to_date}"] || 0
       s[:D] = r["D"]["#{tmp.to_date}"] || 0
       ret[:items] << s
       tmp += 1.day
     end while tmp <= ed 
  
    render json: ret
  end
  
          
      
  
end #class
