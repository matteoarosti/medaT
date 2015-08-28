class RepairProcessingsController < ApplicationController
  
  def extjs_sc_model
   'RepairProcessing'
  end   

  
  def get_combo_data
    ret = {}
    model_class = extjs_sc_model.to_s
    ret[:success] = true
    ret[:items] = model_class.constantize.select("repair_processings.*, 
        concat(repair_components.description_it, ' | ', repair_positions.description_it, ' | ', repair_processings.description_it) as name").joins(:repair_component, :repair_position).order("repair_components.description_it, repair_components.description_it, repair_processings.description_it").limit(500)
    render json: ret
  end

  
end
