r_email_to = %w(
 gen.alampugnani@cma-cgm.com
 gen.lgabetta@cma-cgm.com
 gen.pnazari@cma-cgm.com
 gen.ppuppo@cma-cgm.com
 ssc.itequipment@cma-cgm.com
 m.galli@globalservice.an.it
 m.galli@fmg.eu
 m.testini@fmg.eu
)

SendCsvStd.new.send_TMOV(3, [3], r_email_to, Time.zone.yesterday.at_beginning_of_day, Time.zone.yesterday.at_end_of_day, true)
SendCsvStd.new.send_GIAC(3, [3], r_email_to)
SendCsvStd.new.send_GIAC_sint(3, [3], r_email_to)
SendCsvStd.new.send_booking_analytics(3, [3], r_email_to)