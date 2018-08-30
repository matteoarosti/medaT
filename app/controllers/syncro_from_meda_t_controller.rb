class SyncroFromMedaTController < ApplicationController
  
  #al momento disattivo controllo utente e CSRF session
  protect_from_forgery with: :null_session
  skip_before_action :authenticate_user!
  
  def get_discharge_hi_for_container
    ship = Ship.find_by_name(params[:ship_name])
    hi = HandlingItem.where(container_number: params[:container_number], ship_id: ship.id, voyage: params[:voyage])
    render json: {:success => true, :data=>{hi: hi}}
  end   
  
end
