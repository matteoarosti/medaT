class SendActivityCustomerReport
  
  def call
    items = HandlingHeader.where('1=1').not_closed.locked_INSPECT
  end
  
end