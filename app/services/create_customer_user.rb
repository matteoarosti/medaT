#
# example
# rails runner "CreateCustomerUser.new.call('<username>', '<email>', '<name>', '<psw min 8>', '3 <customer_id>', nil <shipwoner_flt>)"
#

class CreateCustomerUser
  def call(username, email, name, psw, customer_flt, shipowner_flt)
    user = User.create(
        username: username, 
        email: email, 
        name: name,
        password: psw,
        password_confirmation: psw,
        customer_flt: customer_flt,
        shipowner_flt: shipowner_flt,
        role: 8) #role 8: customer
    puts user.errors.to_yaml
    
    puts "--------------------------------------------------------------------------------------"
    puts "Utente creato per #{name}"
    puts "--------------------------------------------------------------------------------------"
    puts "username: #{username}"
    puts "email: #{email}"
    puts "psw: #{psw}"    
    puts "--------------------------------------------------------------------------------------"
  end
end