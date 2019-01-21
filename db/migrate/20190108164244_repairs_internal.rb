class RepairsInternal < ActiveRecord::Migration
  def change    
    add_column      :repair_processings, :suggest_for_int_on_inspect, :boolean  #if true: puo' essere dichiarata (eseguita internamente) in fase di ispezione (danneggiato)
    add_column      :repair_processings, :suggest_for_off_on_inspect, :boolean  #if true: puo' essere dichiarata (da precaricare in prev. per officina) in fase di ispezione (danneggiato)
    
    add_column      :repair_estimate_items, :is_internal, :boolean              #questa operazione e' stata eseguita internamente, da non considerare nel preventivo        
  end
end
