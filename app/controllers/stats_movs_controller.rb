class StatsMovsController < ApplicationController


  #tab dashboard
  def tab_dashboard
    render :partial => "tab_dashboard"
  end
    
     
  
  
  def graph_data_movs_by_hours
    ret = {}
    ret[:items] = []
    r = {'IE' => {}, 'OE' => {}, 'LE' => {}, 'DE' => {}, 'IF' => {}, 'OF' => {}, 'LF' => {}, 'DF' => {}}

=begin          
    #raggruppo i movimenti aperti in base al lock
     gcs = HandlingItem.select('hour(datetime_op) as date_op, handling_items.handling_type, handling_item_type, count(*) as t_cont').where('operation_type=?', 'MT').group('hour(datetime_op), handling_items.handling_type, handling_item_type')     
     ### rallenta troppo e non serve!   gcs = gcs.joins(:handling_header)
     ###gcs = gcs.where('DATE(datetime_op) > NOW() - INTERVAL 35 DAY')
     gcs = gcs.order('hour(datetime_op) DESC').limit(200)
=end

    where_by_form_values = ' '
        
    unless params[:formValues].nil?  
      where_by_form_values += " AND datetime_op >= '#{Time.zone.parse(params[:formValues]['flt_date_from']).beginning_of_day}'"  unless params[:formValues]['flt_date_from'].blank?
      where_by_form_values += " AND datetime_op <= '#{Time.zone.parse(params[:formValues]['flt_date_to']).end_of_day}'"  unless params[:formValues]['flt_date_to'].blank?        
    end
      
    gcs = HandlingHeader.find_by_sql("
      SELECT
        dd.op_h, dd.handling_type, dd.handling_item_type, dd.container_FE, sum(dd.t_cont) as t_cont
      FROM (        
          SELECT date(datetime_op) as op_dd, hour(datetime_op) as op_h, hi.handling_type, hi.handling_item_type, hi.container_FE, 
           count(*) as t_cont 
          FROM handling_headers hh 
          INNER JOIN handling_items hi ON hh.id = hi.handling_header_id
          WHERE (hi.operation_type='MT' and hi.container_FE <>'')
            #{where_by_form_values}
          GROUP BY date(datetime_op), hour(datetime_op), hi.handling_type, hi.handling_item_type, container_FE
      ) as dd
      GROUP BY dd.op_h, dd.handling_type, dd.handling_item_type, container_FE
    ")
     
     
     
     gcs.each do |gc|
       if gc.handling_item_type == 'O_LOAD'
         r["L#{gc.container_FE}"]["#{gc.op_h}"] = r["L#{gc.container_FE}"]["#{gc.op_h}"].to_i + gc.t_cont;
       elsif gc.handling_item_type == 'I_DISCHARGE'
         r["D#{gc.container_FE}"]["#{gc.op_h}"] = r["D#{gc.container_FE}"]["#{gc.op_h}"].to_i + gc.t_cont;
       else
        r["#{gc.handling_type}#{gc.container_FE}"]["#{gc.op_h}"] = r["#{gc.handling_type}#{gc.container_FE}"]["#{gc.op_h}"].to_i + gc.t_cont;
       end
     end

 
     
    #array per le 24 ore          
     24.times do |hm|
       
       #ToDo: devo aggiungere +2 alle ore????? (timezone)
       if hm >= 2 
         h = hm - 2
       else
         h = hm + 22
       end
       #h = hm
       
       s = {}
       s[:op] = hm
       s[:IE]  = r["IE"]["#{h}"] || 0
       s[:OE]  = r["OE"]["#{h}"] || 0
       #s[:LE]  = r["LE"]["#{h}"] || 0
       #s[:DE]  = r["DE"]["#{h}"] || 0
       s[:IF]  = r["IF"]["#{h}"] || 0
       s[:OF]  = r["OF"]["#{h}"] || 0
       #s[:LF]  = r["LF"]["#{h}"] || 0
       #s[:DF]  = r["DF"]["#{h}"] || 0         
       ret[:items] << s       
     end
       
    render json: ret
  end
  
  
end #class
