class IsoEquipment < ActiveRecord::Base

  belongs_to :equipment
  
  def equipment_id_Name
   self.equipment.send(Equipment.combo_displayField) if self.equipment
  end  
  
  scope :extjs_default_scope, -> {}

  def self.as_json_prop()
      return {
         :methods => :equipment_id_Name
       }
  end   
    
  def self.get_id_by_iso(iso)
    if IsoEquipment.where(:iso => iso).any?
      IsoEquipment.where(:iso => iso).first.equipment_id
    else
      return ''
    end
  end
end
