class ShipownerAddFlags < ActiveRecord::Migration
  def change
    add_column :shipowners, :manage_empty, :boolean                     #per la compagnia si gestiscono i vuoti
    add_column :shipowners, :manage_full,  :boolean                     #per la compagnia si gestiscono i pieni
    add_column :shipowners, :auth_required_for_o_emptying,  :boolean    #serve authorizzazione doganale per uscita per svuotamento       
  end
end
