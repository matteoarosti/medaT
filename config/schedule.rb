# Learn more: http://github.com/javan/whenever

# Istruzioni per rigenerare /etc/crontab
# $ whenever -w

set :environment, "development"

every 3.minute do
  runner "SendEmailHiNotify.new.call"
end

every 2.hours do  
  #Codeco CMA  
  runner "SendCodeco.new.call(3, [3], 'app.editr@edi.cma-cgm.com')"  
end

every 2.hours, at: 30 do
  #Codeco COSCO
  runner "SendCodecoStd.new.call(12, [12], ['E'], 'edifact@fmg.eu;matteo.arosti@gmail.com', 'ITAOIY3', 'COSCO', 1000000, 2000000, 'CODECO COSCO')"
end

#Cosco .xls
every 1.day, :at => '8:00 am' do
  runner "SendCsvStd.new.send_TMOV(12, [12], 'r.carbonari@fmg.eu;matteo.arosti@gmail.com;c.parrella@fmg.eu', Time.zone.yesterday.at_beginning_of_day, Time.zone.yesterday.at_end_of_day, true)"
  runner "SendCsvStd.new.send_GIAC(12, [12], 'r.carbonari@fmg.eu;matteo.arosti@gmail.com;c.parrella@fmg.eu')"
  runner "SendCsvStd.new.send_GIAC_sint(12, [12], 'r.carbonari@fmg.eu;matteo.arosti@gmail.com;c.parrella@fmg.eu')"
end
every 1.day, :at => '10:00 am' do
  runner "SendCsvStd.new.send_TMOV(12, [12], 'r.carbonari@fmg.eu;matteo.arosti@gmail.com;c.parrella@fmg.eu', Time.zone.today.at_beginning_of_day, Time.zone.now, true)"
  runner "SendCsvStd.new.send_GIAC(12, [12], 'r.carbonari@fmg.eu;matteo.arosti@gmail.com;c.parrella@fmg.eu')"
  runner "SendCsvStd.new.send_GIAC_sint(12, [12], 'r.carbonari@fmg.eu;matteo.arosti@gmail.com;c.parrella@fmg.eu')"
end


#riavvio ambiente spring (sembra ogni tanto bloccare le chiamate rails schedulate
every 5.hours, :at => '2:20 am' do 
  command "cd /var/www/rails-app/medaT; bin/spring stop"
end
