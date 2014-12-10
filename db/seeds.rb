# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
user = CreateAdminService.new.call
puts 'CREATED ADMIN USER: ' << user.email

Shipowner.create(name: 'MAERSK LINE', short_name: 'MSL', email: 'info@maerskline.com', estimate_hourly_cost: 9.0)
Shipowner.create(name: 'CMA', short_name: 'CMA', email: 'info@cma-cgm.com', estimate_hourly_cost: 9.0)
Shipowner.create(name: 'SAF', short_name: 'SAF', email: 'info@saf.com', estimate_hourly_cost: 9.0)
Shipowner.create(name: 'HAN', short_name: 'HAN', email: 'info@han.com', estimate_hourly_cost: 9.0)
Shipowner.create(name: 'SGL', short_name: 'SGL', email: 'info@sgl.com', estimate_hourly_cost: 9.0)

Ship.create(name: 'BF MELODY', short_name: 'BFML', call_sign: 'VCD6D')
Ship.create(name: 'KING BYRON', short_name: 'KYBY', call_sign: 'QW5D7')
Ship.create(name: 'CLIPPER', short_name: 'CLPR', call_sign: 'GVFD56SD')
Ship.create(name: 'DIRHAMI', short_name: 'DRHM', call_sign: 'VCD6D')

Equipment.create(equipment_type: '20DV', size: '20', sizetype: '20 FOOT BOX', iso: '2200')
Equipment.create(equipment_type: '20RF', size: '20', sizetype: '20 FOOT BOX REEFER', iso: '2230')
Equipment.create(equipment_type: '40DV', size: '40', sizetype: '40 FOOT BOX', iso: '4200')
Equipment.create(equipment_type: '40FL', size: '40', sizetype: '40 FOOT FLAT RACK', iso: '4260')
Equipment.create(equipment_type: '40HC', size: '40', sizetype: '40 BOX HIGH CUBE', iso: '4500')
Equipment.create(equipment_type: '40RF', size: '40', sizetype: '40 BOX REEFER', iso: '4532')

Port.create(port_code: 'ITAOI', city: 'ANCONA', country: 'ITALY')
Port.create(port_code: 'ITRVN', city: 'RAVENNA', country: 'ITALY')
Port.create(port_code: 'ITTRS', city: 'TRIESTE', country: 'ITALY')
Port.create(port_code: 'ITTAR', city: 'TARANTO', country: 'ITALY')
Port.create(port_code: 'ITGIT', city: 'GIOIA TAURO', country: 'ITALY')
Port.create(port_code: 'CYLMA', city: 'LYMASSOL', country: 'CYPRUS')
Port.create(port_code: 'EGALY', city: 'ALESSANDRIA', country: 'EGYPT')
Port.create(port_code: 'GRPIR', city: 'PIRAEUS', country: 'GREECE')
Port.create(port_code: 'LBBRU', city: 'BEIRUT', country: 'LEBANON')

Carrier.create(name: 'ATS', address: 'VIA MARCONI 10', zip_code: '60020', city: 'POLVERIGI', country: 'ITALY', country: 'info@ats.it')
Carrier.create(name: 'MAUGERI', address: 'VIA XXIX SETTEMBRE, 9', zip_code: '60031', city: 'ANCONA', country: 'ITALY', country: 'info@maugeri.it')
Carrier.create(name: 'GAI TRASPORTI', address: 'P.ZZA CAVOUR, 15', zip_code: '60031', city: 'ANCONA', country: 'ITALY', country: 'info@gaitrasporti.it')

Booking.create(num_booking: '123456')
Booking.create(num_booking: '77777777')
