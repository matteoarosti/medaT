class AddConfigBayatoShips < ActiveRecord::Migration
  def change
    add_column   :ships, :j_config, :text  
  end
end
