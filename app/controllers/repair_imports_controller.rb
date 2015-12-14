class RepairImportsController < ApplicationController
  
  # Form per upload e caricamento file
  def import_file
  end
  
  
  def exe_import_file
    file = params[:file]
    spreadsheet = open_spreadsheet(file)
    
    render json: {:success => true}
  end
  
end
