class AlterEquipmentAddColors < ActiveRecord::Migration
  def change
    add_column   :equipment, :sp_bg_color, :string, limit: 30
    add_column   :equipment, :sp_font_color, :string, limit: 30  
  end
end
