class Shipowner < ActiveRecord::Base

 has_many :ships
 
 #obbligatorio per extjs_sc
 scope :extjs_default_scope, -> { }

 def self.get_id_by_name(short_name)
   Shipowner.where(:short_name => short_name).first.id
 end

end
