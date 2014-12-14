class ImportHeadersController < ApplicationController

  def extjs_sc_model
    'ImportHeader'
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
    
    
    #redirect_to root_url, notice: "Items imported."
    
    #restituisco il numero di id dell'import e il numero di righe
    hi = ImportHeader.find(import_header_id)
    ret = {}
    ret[:success] = true
    ret[:import_id] = import_header_id
    ret[:num_rows] = hi.import_items.count 
    render json: ret 
  end
  
  

  def check_container
    retval = ImportHeader.check_digit(params[:container_number])
    redirect_to :controller => 'import_headers', :action => 'index', :notice => "Container Checked."
  end


# Form per upload e caricamento file
def new_import
 @item = ImportHeader.new
end

# Form per find import (in base a nave e viaggio)
def find_import
 @item = ImportHeader.new
end

# Verifico l'esistenza di un import (dato nave e viaggio)
def search_import
 ret = {}
 ih = ImportHeader.find_by :ship_id => params[:ship_id], :voyage => params[:voyage]
 if ih.nil?
   ret[:success] = false
 else
   ret[:success] = true
   ret[:import_id] = ih.id
 end
 render json: ret
end


def open_import
 @ih = ImportHeader.find(params[:import_header_id])
end

def get_import_row
 @ih = ImportHeader.find(params[:import_header_id])
 ret = {}
   ret[:items] = @ih.import_items.order(:container_number).as_json(ImportItem.as_json_prop)
   ret[:success] = true
   render json: ret 
end


def get_voyage_by_ship
 ret = {}
 ret[:success] = true
 ret[:items] = ImportHeader.where("ship_id = ?", params[:ship_id]).where("import_status = ?", params[:import_status])
 render json: ret
end


end
