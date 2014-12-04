class ImportHeadersController < ApplicationController

  def extjs_sc_model
    'ImportHeaders'
  end

#  def import_file(ship_id, voyage, import_type)
  def import_file

    #ship_id = Ship.get_id_by_name(params[:ship])
    
    ship_id = params[:ship_id]

    #Prima verifica se l'importazione e' gia' stata fatta
    if ImportHeader.check_record_exist(ship_id, params[:voyage], params[:ld]) == true
      redirect_to :controller => :import_headers, :action => :index, notice: "Items already imported."
      return
    end

    #Crea il record nella tabella Import_Headers
    import_header_id = ImportHeader.add_record(ship_id, params[:voyage], params[:ld])

    #Lettura del file excel
    ImportHeader.import(import_header_id, params[:file])
    redirect_to root_url, notice: "Items imported."
  end

  def check_container
    retval = ImportHeader.check_digit(params[:container_number])
    redirect_to :controller => 'import_headers', :action => 'index', :notice => "Container Checked."
  end


# Form per upload e caricamento file
def new_import
end

def new_import_exe
end




end
