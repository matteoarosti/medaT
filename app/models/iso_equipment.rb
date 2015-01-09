class IsoEquipment < ActiveRecord::Base

  scope :extjs_default_scope, -> {}

  def self.get_id_by_iso(iso)
    IsoEquipment.where(:iso => iso).first.equipment_id
  end
end
