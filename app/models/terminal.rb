class Terminal < ActiveRecord::Base

  scope :extjs_default_scope, -> {}
    
  #gestione permessi in base a utente
  def self.default_scope
    if !User.current.nil? && !User.current.terminal_flt.blank?
     if User.current.terminal_flt.include?(',')
       return self.where("id IN (#{User.current.terminal_flt})")
     else
       return self.where("id = ?", User.current.terminal_flt)
     end
    end
    return nil
  end
    
          
  
end
