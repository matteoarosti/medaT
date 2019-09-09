class SyncroFromMedaTController < ApplicationController
  
  #al momento disattivo controllo utente e CSRF session
  protect_from_forgery with: :null_session
  skip_before_action :authenticate_user!
  
  def get_container_per_booking
    if params[:num_booking].empty?
      render json: {:success => false, :msg_error=>"Numero booking obbligatorio"}        
      return
    end
    
    hh = HandlingHeader.where(num_booking: params[:num_booking]) #Verificare: lo trovo veramente in num_booking??
    render json: {:success => true, :data=>{hi: hh}}  #ToDo: ritornare solo num_container???     
  end
  
  
  ######################################################################################
  def get_discharge_hi_for_container
  ######################################################################################
    if params[:ship_imo_code].empty?
      render json: {:success => false, :msg_error=>"Il codice IMO della nava non puo' essere vuoto"}
      return
    end  
    
    ship = Ship.find_by_imo_code(params[:ship_imo_code])
      
    if ship.nil?  
      render json: {:success => false, :msg_error=>"Nave non trovata con codice IMO #{params[:ship_imo_code]}"}
      return
    end
    
    hi = HandlingItem.joins(:handling_header).where(handling_headers: {container_number: params[:container_number]}, handling_item_type: 'I_DISCHARGE', ship_id: ship.id).where("SUBSTR(voyage, 1, #{params[:voyage].size}) = '#{params[:voyage]}'").first
    #hi = HandlingItem.joins(:handling_header).where(handling_headers: {container_number: params[:container_number]}, ship_id: ship.id, voyage: params[:voyage]).first
    #hi = HandlingItem.joins(:handling_header).where(handling_headers: {container_number: params[:container_number]}, ship_id: ship.id).first
    if hi
      ret_movs = hi.handling_header.handling_items.order(:datetime_op, :id).select {|r| ['I_DISCHARGE', 'O_EMPTYING'].include?(r.handling_item_type)}
    else
      ret_movs = nil
    end    
    render json: {:success => true, :data=>{hi: ret_movs}}
  end
  
  
  
  ######################################################################################
  def send_emptying_auth
  ######################################################################################
    n = ExternalData.create(
      from: params[:from],
      code1: 'AUTH_WP_C',
      code2: params[:container_number],
      code3: params[:ship_imo_code],
      code4: params[:voyage]
    )
    render json: {:success => true, :data=>{item: n}}
  end


end
