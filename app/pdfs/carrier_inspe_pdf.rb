#generazione pdf per invio notifica visia doganale
class CarrierInspePdf < Prawn::Document  
  
  def initialize(default_prawn_options={})
    
      #A5, orizzontale
      default_prawn_options[:page_size] = 'A4'
      default_prawn_options[:page_layout] = :portrait
        
      super(default_prawn_options)
      font_size 6
   end
   
   
###########################################   
  def m_draw(hi)
###########################################
                
    
    define_grid(:columns => 11, :rows => 26, :gutter => 0)
    
    #riga 0
    riga_from = 0
    riga_to   = 0
    grid([riga_from,0], [riga_to,9]).bounding_box do
      text "VISITA DOGANALE N. #{hi.id}, #{hi.inspection_type.name unless hi.inspection_type.nil?}", :size => 12      
    end
    
              
    

    #seconda riga intestazione
    riga_from = riga_to + 1
    riga_to   = riga_from
    grid([riga_from,0], [riga_to, 10]).bounding_box do
      text "Container: #{hi.handling_header.container_number}", :size => 14      
    end
    

        
    
    
    
        
    #riga 1
    riga_from = riga_to + 1
    riga_to   = riga_from
    grid([riga_from,0], [riga_to,1]).bounding_box do write_cell('Marsk/Marche', hi.handling_header.shipowner.name) end
    grid([riga_from,2], [riga_to,3]).bounding_box do write_cell('Number/Numeri', [hi.handling_header.container_number[0..9], hi.handling_header.container_number[10..100]].join(' - ')) end
    grid([riga_from,4], [riga_to,5]).bounding_box do write_cell('Location/Luogo', 'ANCONA') end
    grid([riga_from,6], [riga_to,7]).bounding_box do write_cell('Date/Data', hi.datetime_op.strftime("%d/%m/%Y")) end
    grid([riga_from,8], [riga_to,8]).bounding_box do write_cell('Time/Ora', hi.datetime_op.strftime("%H:%M")) end
    grid([riga_from,9], [riga_to,10]).bounding_box do write_cell('Seal/Sigillo', hi.seal_shipowner) end

      
  
    #il booking lo ricerco nei dettagli precedenti (per data/ora) al dettaglio in linea
    hi_search_booking_item = hi.search_booking_item()
    hi_search_booking      = !hi_search_booking_item.nil? ? hi_search_booking_item.booking : nil
      
          
    #riga 2
    riga_from = riga_to + 1
    riga_to   = riga_from
    grid([riga_from,0], [riga_to,1]).bounding_box do write_cell('Equipment', hi.handling_header.equipment.equipment_type) end
    grid([riga_from,2], [riga_to,5]).bounding_box do write_cell('Terminal',  !hi.terminal.nil? ? hi.terminal.code : '') end    
    grid([riga_from,6], [riga_to,7]).bounding_box do write_cell('Frigo Temp.', !hi_search_booking_item.nil? ? hi_search_booking_item.temperature.to_s : '') end
    grid([riga_from,8], [riga_to,8]).bounding_box do write_cell('Frigo Humid.', !hi_search_booking_item.nil? ? hi_search_booking_item.humidity.to_s : '') end      
    grid([riga_from,9], [riga_to,10]).bounding_box do write_cell('Frigo Vent.', !hi_search_booking_item.nil? ? hi_search_booking_item.ventilation.to_s : '') end


      
            
      
    #riga 3
     
      #nave e viaggio, se non presenti, vengon presi dal booking (se presente)
      out_voyage = hi.voyage || ''
      out_ship_name =  !hi.ship.nil? ? hi.ship.name : ''

      
        if !hi_search_booking.nil?
          out_voyage = hi_search_booking.voyage if out_voyage.empty?
          out_ship_name = hi_search_booking.ship.name if out_ship_name.empty?
        end
      
    riga_from = riga_to + 1
    riga_to   = riga_from
    grid([riga_from,0], [riga_to,5]).bounding_box do write_cell('Vessel', out_ship_name) end
    grid([riga_from,6], [riga_to,7]).bounding_box do write_cell('Voyager n.', out_voyage) end
    grid([riga_from,8], [riga_to,10]).bounding_box do write_cell('Booking ref.', !hi_search_booking.nil? ? hi_search_booking.num_booking : '') end

      
      
    mv_import_export = hi.is_import_export  
    if mv_import_export == 'E'
      out_weight = hi.handling_header.weight_exp
    else
      out_weight = hi.handling_header.weight_imp
    end 
      
    #riga 4
    riga_from = riga_to + 1
    riga_to   = riga_from
    grid([riga_from,0], [riga_to,3]).bounding_box do write_cell('Shipper', !hi.shipper.nil? ? hi.shipper.name : '') end
    grid([riga_from,4], [riga_to,5]).bounding_box do write_cell('Applicant', hi.driver) end
    grid([riga_from,6], [riga_to,7]).bounding_box do write_cell('Goods weight', out_weight.to_s) end #ToDo (Imp o Exp?)      
    grid([riga_from,8], [riga_to,10]).bounding_box do write_cell('Goods description', '') end #???

    #riga 5
    riga_from = riga_to + 1
    riga_to   = riga_from + 1
    grid([riga_from,0], [riga_to,10]).bounding_box do write_cell('Remarsk/Annotazioni', '') end
      
    
    #note per VUOTO
    riga_from = riga_to + 1
    riga_to   = riga_from + 1
    
    annotazione = ''
 
      
      
    grid([riga_from,0], [riga_to,10]).bounding_box do write_cell('Annotazioni', annotazione, :content_size => 5) end
    
      

    #riga 6
    riga_from = riga_to + 1
    riga_to   = riga_from + 1
    
      #delivered, received
      ar_icop = ['I.CO.P. s.rl.', 'Via L.go Mare Vanvitelli, 68', '60121 - Ancona', 'Italia']
      ar_shipper = []  
      ar_shipper = [hi.shipper.name, hi.shipper.address, [hi.shipper.zip_code, hi.shipper.city].join(', '), hi.shipper.country] unless hi.shipper.nil?
    
      ar_delivered_by = ar_icop
      ar_received_by  = ar_shipper        
      
    
    grid([riga_from,0], [riga_to,5]).bounding_box do write_cell_ar('Deliverd by', ar_delivered_by) end
    grid([riga_from,6], [riga_to,10]).bounding_box do write_cell_ar('Recived by', ar_received_by) end

    #riga 7
    riga_from = riga_to + 1
    riga_to   = riga_from + 1
    grid([riga_from,0], [riga_to,5]).bounding_box do write_cell('Signature/Firma', '') end
    grid([riga_from,6], [riga_to,10]).bounding_box do write_cell('Signature/Firma', '') end
    
      
    #Note compagnia
      riga_from = riga_to + 3
      riga_to   = riga_from + 5            
     grid([riga_from,0], [riga_to,10]).bounding_box do write_cell('Note per compagnia', nota_compagnia(hi.handling_header.shipowner), :content_size => 7) end        
        
      
      
    #per accettazione
    riga_from = 25
    riga_to   = riga_from
    grid([riga_from,6], [riga_to,10]).bounding_box do write_cell('Per accettazione', '') end
      
      
      
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
  
        
  
  
  def nota_compagnia(shipowner)    
      return ""
  end
  
  
  
  
end