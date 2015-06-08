#generazione pdf per invio notifica movimentazione a carrier
class CarrierMovPdf < Prawn::Document  
  
  def initialize(default_prawn_options={})
    
      #A5, orizzontale
      default_prawn_options[:page_size] = 'A4'
      default_prawn_options[:page_layout] = :portrait
        
      super(default_prawn_options)
      font_size 6
   end
   
   
   
  def m_draw(hi)
    
    
    define_grid(:columns => 11, :rows => 26, :gutter => 0)
    
    #riga 0
    riga_from = 0
    riga_to   = 0
    grid([riga_from,0], [riga_to,9]).bounding_box do
      text "EQUIPMENT INTERCHANGE RECEIPT N. ______ / _________", :size => 14      
    end
     
    grid([riga_from,10], [riga_to,10]).bounding_box do
      line_width 1
      move_down 10
      indent(3) do
        text 'OUT', :size => 16
      end
      stroke_bounds #bordo
    end
    
    
        
    #riga 1
    riga_from = riga_to + 2
    riga_to   = riga_from
    grid([riga_from,0], [riga_to,1]).bounding_box do write_cell('Marsk/Marche', hi.handling_header.container_number[0..3]) end
    grid([riga_from,2], [riga_to,3]).bounding_box do write_cell('Number/Numeri', [hi.handling_header.container_number[4..9], hi.handling_header.container_number[10..100]].join(' - ')) end
    grid([riga_from,4], [riga_to,5]).bounding_box do write_cell('Location/Luogo', 'ANCONA') end
    grid([riga_from,6], [riga_to,7]).bounding_box do write_cell('Date/Data', hi.datetime_op.strftime("%d/%m/%Y")) end
    grid([riga_from,8], [riga_to,8]).bounding_box do write_cell('Time/Ora', hi.datetime_op.strftime("%H:%M")) end
    grid([riga_from,9], [riga_to,10]).bounding_box do write_cell('Seal/Sigillo', 'INTATTO') end #TODO (shipowner o others?)
    
    #riga 2
    riga_from = riga_to + 1
    riga_to   = riga_from
    grid([riga_from,0], [riga_to,5]).bounding_box do write_cell('Equipment description', hi.handling_header.equipment.equipment_type) end
    grid([riga_from,6], [riga_to,10]).bounding_box do write_cell('Frigo Temp.', '') end

    #riga 3
    riga_from = riga_to + 1
    riga_to   = riga_from
    grid([riga_from,0], [riga_to,5]).bounding_box do write_cell('Vessel', !hi.ship.nil? ? hi.ship.name: '') end
    grid([riga_from,6], [riga_to,7]).bounding_box do write_cell('Voyager n.', hi.voyage) end
    grid([riga_from,8], [riga_to,10]).bounding_box do write_cell('Booking ref.', !hi.booking.nil? ? hi.booking.num_booking : '') end

    #riga 4
    riga_from = riga_to + 1
    riga_to   = riga_from
    grid([riga_from,0], [riga_to,3]).bounding_box do write_cell('Carrier', !hi.carrier.nil? ? hi.carrier.name : '') end
    grid([riga_from,4], [riga_to,5]).bounding_box do write_cell('Autista', hi.driver) end
    grid([riga_from,6], [riga_to,7]).bounding_box do write_cell('Goods weight', '') end #ToDo (Imp o Exp?)      
    grid([riga_from,8], [riga_to,10]).bounding_box do write_cell('Goods description', '') end #???

    #riga 5
    riga_from = riga_to + 1
    riga_to   = riga_from + 1
    grid([riga_from,0], [riga_to,10]).bounding_box do write_cell('Remarsk/Annotazioni', '') end
      
    
    #note per VUOTO
    riga_from = riga_to + 1
    riga_to   = riga_from + 1
    
    if (hi.container_FE == 'E')
      annotazione = "La I.CO.P. srl declina ogni e qualsiasi responsabilità al momento che il contenitore" + 
      " è stato caricato sull'automezzo. E' obbligo del vettore accertarsi della giusta denomiazione della Compagnia, buon ordine e conddizioni," +
      " tipo, portata e tara del contenitore, ecc." + 
      " \nTrasporto esente da emissione bolla coompagnamento Art. 4 dipr 6-10-78 nr. 627"
    else
      annotazione = ''
    end 
      
      
    grid([riga_from,0], [riga_to,10]).bounding_box do write_cell('Annotazioni', annotazione, :content_size => 5) end
    
      

    #riga 6
    riga_from = riga_to + 1
    riga_to   = riga_from + 1
    
      #delivered, received
      ar_icop = ['I.CO.P. s.rl.', 'Via L.go Mare Vanvitelli, 68', '60121 - Ancona', 'Italia']
      ar_carrier = [hi.carrier.name, hi.carrier.address, [hi.carrier.zip_code, hi.carrier.city].join(', '), hi.carrier.country]
    
      if (hi.handling_type == 'I')
         ar_delivered_by = ar_carrier
         ar_received_by  = ar_icop
      else
        ar_delivered_by = ar_icop
        ar_received_by  = ar_carrier        
      end
    
    grid([riga_from,0], [riga_to,5]).bounding_box do write_cell_ar('Deliverd by', ar_delivered_by) end
    grid([riga_from,6], [riga_to,10]).bounding_box do write_cell_ar('Recived by', ar_received_by) end

    #riga 7
    riga_from = riga_to + 1
    riga_to   = riga_from + 1
    grid([riga_from,0], [riga_to,5]).bounding_box do write_cell('Signature/Firma', '') end
    grid([riga_from,6], [riga_to,10]).bounding_box do write_cell('Signature/Firma', '') end
    
        
  end  #m_draw
  
  
  def write_cell(title, content, p = {})
    line_width 0.5
    move_down 3
    indent(3) do
      text title #, :style=>'bold'
      #text_box(title, :at => [2, 2])
      move_down 4
      text content, :size => p[:content_size] || 8
    end
    stroke_bounds #bordo
  end

  def write_cell_ar(title, content)
    line_width 0.5
    move_down 5
    indent(3) do
      text title #, :style=>'bold'
      move_down 4            
      content.each do |c|
        text c, :size => 8
      end
    end
    stroke_bounds #bordo
  end
  
        
end