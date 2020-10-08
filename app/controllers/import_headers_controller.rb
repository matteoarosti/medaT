class ImportHeadersController < ApplicationController

  def extjs_sc_model
    'ImportHeader'
  end
  
  
  #come lista mostro solo le liste aperte
  ##########################################
   def extjs_sc_list
  ########################################## 
    model_class = extjs_sc_model.to_s
      
    ret = {}
    ret[:items] = model_class.constantize.extjs_default_scope.not_closed.limit(params[:limit]).offset(params[:start]).as_json(model_class.constantize.as_json_prop)
    ret[:total] = model_class.constantize.extjs_default_scope.count
    
    render json: ret
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

    #Esegue un check sui dati prima di seguire l'importazione
    if params[:ld]=='D'
      retval = ImportHeader.check_file_d(params[:file])
    else
      retval = ImportHeader.check_file_l(params[:file])
    end

    if retval != ""
      ret = {}
      ret[:success] = false
      ret[:import_id] = 0
      ret[:num_rows] = 0
      ret[:message] = retval
      render json: ret
      return
    end

    #SE TUTTO OK VIENE CREATO IL RECORD NELLA TABELLA IMPORT_HEADERS \
    #ToDo Gestire la cancellazione dei record se qualcosa non va a buon fine
    #Crea il record nella tabella Import_Headers
    import_header_id = ImportHeader.add_record(ship_id, params[:voyage], params[:ld], params[:handling_type])


    if params[:ld]=='D'
      ImportHeader.import_d(import_header_id, params[:file])
    else
      ImportHeader.import_l(import_header_id, params[:file])
    end


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

# Form per find import (in base a nave e viaggio, mulettista)
def find_import_simple
 @item = ImportHeader.new
 @import_type = params[:import_type]
end



# Verifico l'esistenza di un import (dato nave e viaggio)
def search_import
 ret = {}
 ih = ImportHeader.find_by :ship_id => params[:ship_id], :id => params[:id]
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
   #items = @ih.import_items
   
   #mostro tutti i container dei viaggi che hanno la stessa parte iniziale (es: 1709, 1709 M, ...)
   real_voyage = @ih.voyage.split(' ')[0]
   items = ImportItem.joins(:import_header).where("SUBSTR(import_headers.voyage, 1, #{real_voyage.size}) = '#{real_voyage}'")
   items = items.where(import_headers: {import_type: @ih.import_type, import_status: @ih.import_status, ship_id: @ih.ship_id})
   items = items.where("status IS NULL") unless params[:show_imported].to_i == 1
   items = items.where("container_number LIKE ?", "%#{params[:flt_num_container].upcase}%") if !params[:flt_num_container].to_s.empty?
   items = items.where("sp_pos LIKE ?", "#{params[:flt_pos].upcase}%") if !params[:flt_pos].to_s.empty?
   
   
   #la mossa la uso come punto iniziale di ordinamento (a partire da quella mossa)  
   if !params[:flt_mossa].to_s.empty?
    items = items.order("case when sp_mossa IS NULL then 9 when sp_mossa >= '#{params[:flt_mossa]}' then 1 else 2 end")  
   end
   
   items = items.order(:sp_mossa, :container_number)
   
   ret[:items] = items.as_json(ImportItem.as_json_prop)
   ret[:success] = true
   render json: ret 
end

#per combo ship in find_import
def get_ship_in_find
 params[:import_type]   = params[:import_type] || 'L'
 params[:import_status] = params[:import_status] || 'OPEN'
 ret = {}
 ret[:success] = true
 ret[:items] = ImportHeader.select('ships.id, ships.name').joins(:ship).where("import_type = ?", params[:import_type]).where("import_status = ?", params[:import_status])
 render json: ret
end


def get_voyage_by_ship
 ret = {}
 ret[:success] = true
 ret[:items] = ImportHeader.where("import_type = ? AND ship_id = ?", params[:import_type], params[:ship_id]).where("import_status = ?", params[:import_status]).as_json(ImportHeader.as_json_prop)
 render json: ret
end



end
