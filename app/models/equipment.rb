class Equipment < ActiveRecord::Base

  scope :extjs_default_scope, -> {}


  def self.get_id_by_iso(iso)
    Equipment.where(:iso => iso).first.id
  end

  def self.get_id_by_eqtype(equipment_type)
    Equipment.where(:equipment_type => equipment_type).first.id
  end

  def self.combo_displayField
   'sizetype'
  end

end
