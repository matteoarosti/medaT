class VerifyBookings
  def call
    #recupero tutti gli hi di cui ancora devo inviare la email (se necessario)
    Booking.where('status=?', 'OPEN').each do |bh|

      print "\n----------------------------\n"
      print "\nBooking #{bh.id.to_s} - #{bh.num_booking.to_s}"

      to_close = true
      
      #verifico se tutti gli ii sono chiusi
      bh.booking_items.each do |bi|
       to_close = false if bi.status == 'OPEN'
      end


      if to_close == true
        print "\n-->Chiudo booking: #{bh.num_booking}"
        bh.status = 'CLOSE'
        bh.save!
      end      

    end
  end #call
end #class
