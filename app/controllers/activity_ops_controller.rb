class ActivityOpsController < ApplicationController
  
  def extjs_sc_model
   'ActivityOp'
  end   
  
  
  def get_combo_data_escludi_non_usare
    ret = {}
    model_class = 'ActivityOp'
    
    m_where = "non_usare = false"
    if params[:id_selected]
      m_where += " or id = #{params[:id_selected]}"
    end
    
    ret[:success] = true
    ret[:items] = model_class.constantize
         .where(m_where)
         .order(model_class.constantize.combo_displayField()).limit(500)
    render json: ret   
  end
  
end
