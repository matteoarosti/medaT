class Shipowner < ActiveRecord::Base

 has_many :ships
 
 #obbligatorio per extjs_sc
 scope :extjs_default_scope, -> { } 

end
