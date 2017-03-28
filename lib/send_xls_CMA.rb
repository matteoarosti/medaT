r_email_to = %w(
 m.galli@fmg.eu
 gen.alampugnani@cma-cgm.com
 gen.mbalderi@cma-cgm.com
 gen.grossi@cma-cgm.com
 gen.elastraioli@cma-cgm.com
 matteo.arosti@gmail.com
)

SendCsvStd.new.send_TMOV(3, [3], r_email_to, Time.zone.yesterday.at_beginning_of_day, Time.zone.yesterday.at_end_of_day, true)
SendCsvStd.new.send_GIAC(3, [3], r_email_to)
SendCsvStd.new.send_GIAC_sint(3, [3], r_email_to)
SendCsvStd.new.send_booking_analytics(3, [3], r_email_to)