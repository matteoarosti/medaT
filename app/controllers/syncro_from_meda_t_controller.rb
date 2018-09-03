class SyncroFromMedaTController < ApplicationController
  
  #al momento disattivo controllo utente e CSRF session
  protect_from_forgery with: :null_session
  skip_before_action :authenticate_user!
  
  def get_discharge_hi_for_container
    render json: {:success => false, :msg_error=>"Il codice IMO della nava non puo' essere vuoto"}  if params[:ship_imo_code].empty?
    
    ship = Ship.find_by_imo_code(params[:ship_imo_code])
    render json: {:success => false, :msg_error=>"Nave non trovata con codice IMO #{params[:ship_imo_code]}"}
    
    hi = HandlingItem.joins(:handling_header).where(handling_headers: {container_number: params[:container_number]}, ship_id: ship.id, voyage: params[:voyage]).first
    #hi = HandlingItem.joins(:handling_header).where(handling_headers: {container_number: params[:container_number]}, ship_id: ship.id).first
    ret_movs = hi.handling_header.handling_items.order(:datetime_op).select {|r| ['I_DISCHARGE', 'O_EMPTYING'].include?(r.handling_item_type)}
    render json: {:success => true, :data=>{hi: ret_movs}}
  end   
  
end
