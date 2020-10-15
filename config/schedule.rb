# Learn more: http://github.com/javan/whenever

# Istruzioni per rigenerare /etc/crontab
# $ whenever -w

job_type :runner_file,  "cd :path && bin/rails runner -e :environment :task :output"

set :environment, "development"

every 3.minute do
  runner "SendEmailHiNotify.new.call"
  runner "SendEmailFromLogEvent.new.call"
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
#  runner "SendCsvStd.new.send_GIAC(12, [12], 'r.carbonari@fmg.eu;matteo.arosti@gmail.com;c.parrella@fmg.eu')"
  runner "SendCsvStd.new.send_GIAC_sint(12, [12], 'r.carbonari@fmg.eu;matteo.arosti@gmail.com;c.parrella@fmg.eu')"
end
every 1.day, :at => '10:00 am' do
  runner "SendCsvStd.new.send_TMOV(12, [12], 'r.carbonari@fmg.eu;matteo.arosti@gmail.com;c.parrella@fmg.eu', Time.zone.today.at_beginning_of_day, Time.zone.now, true)"
#  runner "SendCsvStd.new.send_GIAC(12, [12], 'r.carbonari@fmg.eu;matteo.arosti@gmail.com;c.parrella@fmg.eu')"
  runner "SendCsvStd.new.send_GIAC_sint(12, [12], 'r.carbonari@fmg.eu;matteo.arosti@gmail.com;c.parrella@fmg.eu')"
end


#CMA .xls
every 1.day, :at => '00:02 am' do
 runner_file "lib/send_xls_CMA.rb"
end


#riavvio ambiente spring (sembra ogni tanto bloccare le chiamate rails schedulate
every 5.hours, :at => '2:20 am' do 
  command "cd /var/www/rails-app/medaT; bin/spring stop"
end

#generazioen e invio email activity customer report
every 1.day, :at => '11:32 pm' do
  runner "SendActivityCustomerReport.new.call"
end
every 1.hours, :at => '00:20' do
  command "/usr/local/bin/wput -R /share_fe/fe_*.csv ftp://Fatturazione:Sc@mbi01234\\!@192.168.200.5/"
end

#report a commerciale@ con i containers da ispezionare...
every 1.day, :at => '05:02 pm' do
  runner "SendReportToInspect.new.call"
end
