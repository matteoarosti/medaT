class StatsMovsController < ApplicationController


  #tab dashboard
  def tab_dashboard
    render :partial => "tab_dashboard"
  end
    
     

  def graph_date_movs_by_carrier
	graph_data_movs_grouping('CARRIER')
  end
  

  def graph_data_movs_by_hours
	graph_data_movs_grouping
  end

  
  def graph_data_movs_grouping(grouping = 'HOURS')
	###logger.info Time.zone.formatted_offset
    ret = {}
	ar_op = {}
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
	where_by_form_values += " AND carrier_id IS NOT NULL"

	if grouping == 'CARRIER'
			group_by_field = " carrier_id "			
	else
		group_by_field = " hour(datetime_op) "
	end

    unless params[:formValues].nil?  
      where_by_form_values += " AND datetime_op >= '#{Time.zone.parse(params[:formValues]['flt_date_from']).beginning_of_day}'"  unless params[:formValues]['flt_date_from'].blank?
      where_by_form_values += " AND datetime_op <= '#{Time.zone.parse(params[:formValues]['flt_date_to']).end_of_day}'"  unless params[:formValues]['flt_date_to'].blank?        
    end
      


    gcs = HandlingHeader.find_by_sql("
      SELECT
        dd.op_h, dd.handling_type, dd.handling_item_type, dd.container_FE, sum(dd.t_cont) as t_cont
      FROM (        
          SELECT 
			#{group_by_field} as op_h, 
			hi.handling_type, hi.handling_item_type, hi.container_FE, 
           count(*) as t_cont 
          FROM handling_headers hh 
          INNER JOIN handling_items hi ON hh.id = hi.handling_header_id
		  WHERE (hi.operation_type='MT' and hi.container_FE <>'')
            #{where_by_form_values}
          GROUP BY #{group_by_field}, 
		  hi.handling_type, hi.handling_item_type, container_FE
      ) as dd
      GROUP BY dd.op_h, dd.handling_type, dd.handling_item_type, container_FE
    ")
     

     
     gcs.each do |gc|

	   #correggo timezone
	   if grouping == 'HOURS'
		   tt = Time.new(1, 1, 1, gc.op_h, 0, 00, "+00:00")		
		   gc.op_h = tt.localtime.hour	
	   end

       if gc.handling_item_type == 'O_LOAD'
         r["L#{gc.container_FE}"]["#{gc.op_h}"] = r["L#{gc.container_FE}"]["#{gc.op_h}"].to_i + gc.t_cont;
       elsif gc.handling_item_type == 'I_DISCHARGE'
         r["D#{gc.container_FE}"]["#{gc.op_h}"] = r["D#{gc.container_FE}"]["#{gc.op_h}"].to_i + gc.t_cont;
       else
        r["#{gc.handling_type}#{gc.container_FE}"]["#{gc.op_h}"] = r["#{gc.handling_type}#{gc.container_FE}"]["#{gc.op_h}"].to_i + gc.t_cont;
       end

	   ar_op["#{gc.op_h}"] = 1

     end

 

	if grouping == 'HOURS'     
	    #array per le 24 ore          
	     24.times do |h|
	       s = {}
	       s[:op] = h
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
	else
	
		ar_op.each do |h, v|
		   s = {}
	       s[:op] = Carrier.find(h).name[0, 10]
		   
	       s[:IE]  = r["IE"]["#{h}"] || 0
	       s[:OE]  = r["OE"]["#{h}"] || 0
	       s[:IF]  = r["IF"]["#{h}"] || 0
	       s[:OF]  = r["OF"]["#{h}"] || 0
		   s[:global_sum] = s[:IE] + s[:OE] + s[:IF] + s[:OF]
	       ret[:items] << s
		end
		ret[:items] = ret[:items].sort_by { |k| -k[:global_sum] }
	end


    render json: ret
  end
  
  
end #class
