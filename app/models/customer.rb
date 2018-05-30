class Customer < ActiveRecord::Base
  
  scope :extjs_default_scope, -> {}
    
  #gestione permessi in base a utente
  def self.default_scope
    if !User.current.nil? && !User.current.customer_flt.blank?
     if User.current.customer_flt.include?(',')
       return self.where("customers.id IN (#{User.current.customer_flt})")
     else
       return self.where("customers.id = ?", User.current.customer_flt)
     end
    end
    return nil
  end
    
    
end
