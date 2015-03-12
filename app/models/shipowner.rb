class Shipowner < ActiveRecord::Base

 has_many :ships
 
 #obbligatorio per extjs_sc
 scope :extjs_default_scope, -> { }

 def self.get_id_by_name(short_name)
   if Shipowner.where(:short_name => short_name).any?
     Shipowner.where(:short_name => short_name).first.id
   else
     return 0
   end

 end

  def self.combo_displayField
   'short_name'
  end


end
