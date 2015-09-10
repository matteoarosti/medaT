# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

# Istruzioni per rigenerare /etc/crontab
# $ whenever -w


set :environment, "development"

every 3.minute do
  runner "SendEmailHiNotify.new.call"
end

every 2.hours do
  runner "SendCodeco.new.call(3, [3], 'matteo.arosti@gmail.com')"
end


#riavvio ambiente spring (sembra ogni tanto bloccare le chiamate rails schedulate
every 5.hours do 
  command "cd /var/www/rails-app/medaT; bin/spring stop"
end
