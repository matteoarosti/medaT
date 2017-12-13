class BookingCalendarController < ApplicationController
  
  def index
  end
  
  def booking_date_items
    @items = Booking.where('1=1')
    @items = @items.where(eta: params[:date])
    logger.info @items.to_yaml
    #render json: items.as_json(Booking.as_json_prop)
  end
  
end
