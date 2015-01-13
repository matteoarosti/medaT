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
Shipowner.create(name: 'MAERSK LINE', short_name: 'MSK', email: 'info@maerskline.com', estimate_hourly_cost: 9.0)
Shipowner.create(name: 'CMA', short_name: 'CMA', email: 'info@cma-cgm.com', estimate_hourly_cost: 9.0)
Shipowner.create(name: 'SAF', short_name: 'SAF', email: 'info@saf.com', estimate_hourly_cost: 9.0)
Shipowner.create(name: 'HAN', short_name: 'HAN', email: 'info@han.com', estimate_hourly_cost: 9.0)
Shipowner.create(name: 'SGL', short_name: 'SGL', email: 'info@sgl.com', estimate_hourly_cost: 9.0)
Shipowner.create(name: 'HLL', short_name: 'HLL', email: 'info@hll.com', estimate_hourly_cost: 9.0)

Ship.create(name: 'BF MELODY', short_name: 'BDY', call_sign: 'VCD6D')
Ship.create(name: 'KING BYRON', short_name: 'KBYR', call_sign: 'QW5D7')
Ship.create(name: 'CLIPPER', short_name: 'CLP', call_sign: 'GVFD56SD')
Ship.create(name: 'DIRHAMI', short_name: 'DIRH', call_sign: 'VCD6D')
Ship.create(name: 'BF EUPHORIA', short_name: 'BEPHR', call_sign: 'V2CB7')
Ship.create(name: 'ALLEGRO', short_name: 'ALGR', call_sign: 'V2CQ5')
Ship.create(name: 'BF CONFIANZA', short_name: 'CNFZ', call_sign: 'CQFB')
Ship.create(name: 'STINA', short_name: 'STNA', call_sign: 'V2BW7')

Equipment.create(equipment_type: '20DV', size: '20', sizetype: '20 FOOT BOX', iso: '')
Equipment.create(equipment_type: '20RF', size: '20', sizetype: '20 FOOT BOX REEFER', iso: '')
Equipment.create(equipment_type: '40DV', size: '40', sizetype: '40 FOOT BOX', iso: '')
Equipment.create(equipment_type: '40FL', size: '40', sizetype: '40 FOOT FLAT RACK', iso: '')
Equipment.create(equipment_type: '40RF', size: '40', sizetype: '40 FOOT FLAT RACK', iso: '')
Equipment.create(equipment_type: '40OT', size: '40', sizetype: '40 FOOT FLAT RACK', iso: '')
Equipment.create(equipment_type: '40HC', size: '40', sizetype: '40 BOX HIGH CUBE', iso: '')

IsoEquipment.create(iso: '2200', equipment_id: 1)
IsoEquipment.create(iso: '2273', equipment_id: 1)
IsoEquipment.create(iso: '2230', equipment_id: 2)
IsoEquipment.create(iso: '4200', equipment_id: 3)
IsoEquipment.create(iso: '42G1', equipment_id: 3)
IsoEquipment.create(iso: '4260', equipment_id: 4)
IsoEquipment.create(iso: '42R1', equipment_id: 5)
IsoEquipment.create(iso: '4532', equipment_id: 5)
IsoEquipment.create(iso: '4536', equipment_id: 5)
IsoEquipment.create(iso: '42U0', equipment_id: 6)
IsoEquipment.create(iso: '4500', equipment_id: 7)
IsoEquipment.create(iso: '4501', equipment_id: 7)

Port.create(port_code: 'ITAOI', city: 'ANCONA', country: 'ITALY')
Port.create(port_code: 'ITRVN', city: 'RAVENNA', country: 'ITALY')
Port.create(port_code: 'ITTRS', city: 'TRIESTE', country: 'ITALY')
Port.create(port_code: 'ITTAR', city: 'TARANTO', country: 'ITALY')
Port.create(port_code: 'ITGIT', city: 'GIOIA TAURO', country: 'ITALY')
Port.create(port_code: 'CYLMA', city: 'LYMASSOL', country: 'CYPRUS')
Port.create(port_code: 'EGALY', city: 'ALESSANDRIA', country: 'EGYPT')
Port.create(port_code: 'GRPIR', city: 'PIRAEUS', country: 'GREECE')
Port.create(port_code: 'LBBRU', city: 'BEIRUT', country: 'LEBANON')

Carrier.create(name: 'ATS', address: 'VIA MARCONI 10', zip_code: '60020', city: 'POLVERIGI', country: 'ITALY', email: 'info@ats.it')
Carrier.create(name: 'MAUGERI', address: 'VIA XXIX SETTEMBRE, 9', zip_code: '60031', city: 'ANCONA', country: 'ITALY', email: 'info@maugeri.it')
Carrier.create(name: 'GAI TRASPORTI', address: 'P.ZZA CAVOUR, 15', zip_code: '60031', city: 'ANCONA', country: 'ITALY', email: 'info@gaitrasporti.it')

Booking.create(num_booking: '123456')
Booking.create(num_booking: '77777777')
