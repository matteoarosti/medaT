class BookingCalendarController < ApplicationController
  
  layout "application_extjs", only: [:index, :index_mulettista, :piazzale]
  
  def index
  end
  
  def booking_date_items
    @items = Booking.where('1=1')
    @items = @items.where(eta: params[:date])
    #render json: items.as_json(Booking.as_json_prop)
  end
  
end
