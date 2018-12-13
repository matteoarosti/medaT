class AddAttachmentToActivity < ActiveRecord::Migration
  def change
    add_column      :activity_dett_containers, :op_amount, :decimal, precision: 10, scale: 2 #costo per lavorazione su singolo container (esclusa messa a disp.)
    add_column      :activity_dett_containers, :make_available_amount, :decimal, precision: 10, scale: 2 #costo per messa a disposizione container
                                                                                                        #(il campo "amount" e' il complessivo del costo del container)
    add_attachment  :activities, :scan_file
  end
end
