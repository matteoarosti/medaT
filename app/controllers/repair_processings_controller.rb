class RepairProcessingsController < ApplicationController
  
  def extjs_sc_model
   'RepairProcessing'
  end   

  
  def get_combo_data
    ret = {}
    model_class = extjs_sc_model.to_s
    ret[:success] = true
    ret[:items] = model_class.constantize.select("repair_processings.*, 
        concat(repair_components.description_it, ' | ', repair_positions.description_it, ' | ', repair_processings.description_it) as name").joins(:repair_component, :repair_position).order("repair_components.description_it, repair_components.description_it, repair_processings.description_it")
        
    sql_where = ''    
#    if !params[:repair_processing].nil? && !params[:repair_processing].empty? 
#       ret[:items] = ret[:items].or("repair_processings.id = #{params[:repair_processing]}")
#    end
    
    if !params[:flt_repair_component].nil? && !params[:flt_repair_position].nil? && !params[:flt_repair_component].empty? && !params[:flt_repair_position].empty? 
       sql_where += "(repair_component_id = #{params[:flt_repair_component]} and repair_position_id = #{params[:flt_repair_position]}) "
    end
    
    ret[:items] = ret[:items].where(sql_where)
        
    ret[:items] = ret[:items].limit(2500)    
    render json: ret
  end

  
end
