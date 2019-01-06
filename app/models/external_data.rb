class ExternalData < ActiveRecord::Base
  
  def self.is_auth_for_o_emptying(container_number, imo_code, voyage)
    self.where(code1: 'AUTH_WP_C', code2: container_number, code3: imo_code, code4: voyage).exists?
  end
  
end
