class ImportItemsController < ApplicationController

  def extjs_sc_model
    'ImportItems'
  end


  def import
    ImportItem.import(params[:file])
    redirect_to root_url, notice: "Items imported."
  end
  
  
 #################################################  
  def set_ok
 #################################################    
   rec = ImportItem.find(params[:rec_id])

   #Determina la tipologia del movimento da import_headers
   import_type = rec.import_header.import_type
   if import_type == 'L'
     import_L(rec, params)
   else
     import_D(rec, params)
   end

   rec.status = 'OK'
   rec.notes = params[:check_form][:notes] unless params[:check_form][:notes].blank?
   rec.save!
   ret = {}
   ret[:success] = true
   ret[:data] = rec.as_json()
   render json: ret
  end

 #################################################  
  def set_damaged
 #################################################    
    rec = ImportItem.find(params[:rec_id])
 
    #Determina la tipologia del movimento da import_headers
    import_type = rec.import_header.import_type
    if import_type == 'L'
      import_L(rec, params, 'DAMAGED')
    else
      import_D(rec, params, 'DAMAGED')
    end
 
    rec.status = 'DAMAGED'
    rec.notes = params[:check_form][:notes] unless params[:check_form][:notes].blank?
    rec.save!
    ret = {}
    ret[:success] = true
    ret[:data] = rec.as_json()
    render json: ret
  end

 #SBARCO ####################################
  def import_D(rec, params, lock_type = nil)
 #################################################    
    hh = HandlingHeader.create_new(rec, params)
    hi = hh.handling_items.new()
    hi.datetime_op = Time.now
    unless params[:check_form][:datetime_op_date].blank? || params[:check_form][:datetime_op_time].blank?
      hi.datetime_op = generate_datetime(params[:check_form][:datetime_op_date], params[:check_form][:datetime_op_time])      
    end
    hi.notes = params[:check_form][:notes] unless params[:check_form][:notes].blank?
    hi.handling_item_type = "I_DISCHARGE"
    hi.handling_type = "I"
    hi.container_FE = rec.container_status
    hi.ship_id = rec.import_header.ship_id
    hi.voyage = rec.import_header.voyage
    
    #se supera i vari controlli salvo il dettalio e aggiorno la testata
    validate_insert_item = hh.validate_insert_item(hi)
    if validate_insert_item[:is_valid]
      hi.set_lock(lock_type) unless lock_type.nil? #eventuale flag DAMAGE
      hi.save!()
      r = hh.sincro_save_header(hi)
            
      ret_status  = r[:success]
      message     = r[:message]
    end
  end

 #IMBARCO ###############################
  def import_L(rec, params, lock_type = nil)
 #################################################   
     hh = HandlingHeader.find_exist(rec, params)
     hi = hh.handling_items.new()
     hi.datetime_op = Time.now
     unless params[:check_form][:datetime_op_date].blank? || params[:check_form][:datetime_op_time].blank?
      hi.datetime_op = generate_datetime(params[:check_form][:datetime_op_date], params[:check_form][:datetime_op_time])      
     end
     hi.notes = params[:check_form][:notes] unless params[:check_form][:notes].blank?
     hi.handling_item_type = "O_LOAD"
     hi.handling_type = "O"
     hi.container_FE = rec.container_status
     hi.ship_id = rec.import_header.ship_id
     hi.voyage = rec.import_header.voyage
          
     #se supera i vari controlli salvo il dettalio e aggiorno la testata
     validate_insert_item = hh.validate_insert_item(hi)
     if validate_insert_item[:is_valid]
       hi.set_lock(lock_type) unless lock_type.nil? #eventuale flag DAMAGE
       hi.save!()       
       r = hh.sincro_save_header(hi) 
                                     
       ret_status  = r[:success]
       message     = r[:message]
     end
   end

end
