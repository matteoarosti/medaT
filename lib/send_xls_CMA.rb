r_email_to = 'm.arosti@apracs.it;matteo.arosti@gmail.com'

SendCsvStd.new.send_TMOV(3, [3], r_email_to, Time.zone.yesterday.at_beginning_of_day, Time.zone.yesterday.at_end_of_day, true)
SendCsvStd.new.send_GIAC(3, [3], r_email_to)
SendCsvStd.new.send_GIAC_sint(3, [3], r_email_to)