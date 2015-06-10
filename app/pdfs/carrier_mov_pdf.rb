#generazione pdf per invio notifica movimentazione a carrier
class CarrierMovPdf < Prawn::Document  
  
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
    
    text_IO = '??'
    if (hi.handling_type == 'O')        
      text_IO = 'OUT'
    elsif (hi.handling_type == 'I')
      text_IO = 'IN'
    end


    text_FE = '??'
    if (hi.container_FE == 'F')        
      text_FE = 'FULL'
    elsif (hi.container_FE == 'E')
      text_FE = 'EMPTY'
    end
            
    
    define_grid(:columns => 11, :rows => 26, :gutter => 0)
    
    #riga 0
    riga_from = 0
    riga_to   = 0
    grid([riga_from,0], [riga_to,9]).bounding_box do
      text "EQUIPMENT INTERCHANGE RECEIPT N. #{hi.id}", :size => 12      
    end
    
              
    grid([riga_from,10], [riga_to,10]).bounding_box do
      line_width 1
      move_down 10
      indent(3) do        
          text text_IO, :size => 16
      end
      stroke_bounds #bordo
    end
    

    #seconda riga intestazione
    riga_from = riga_to + 1
    riga_to   = riga_from
    grid([riga_from,0], [riga_to, 10]).bounding_box do
      text "Container: #{hi.handling_header.container_number}, #{text_IO}, #{text_FE}", :size => 14      
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
    
    #riga 2
    riga_from = riga_to + 1
    riga_to   = riga_from
    grid([riga_from,0], [riga_to,5]).bounding_box do write_cell('Equipment description', hi.handling_header.equipment.equipment_type) end
    grid([riga_from,6], [riga_to,10]).bounding_box do write_cell('Frigo Temp.', '') end

    #riga 3
     
      #nave e viaggio, se non presenti, vengon presi dal booking (se presente)
      out_voyage = hi.voyage || ''
      out_ship_name =  !hi.ship.nil? ? hi.ship.name : ''
      if !hi.booking.nil?
        out_voyage = hi.booking.voyage if out_voyage.empty?
        out_ship_name = hi.booking.ship.name if out_ship_name.empty?
      end
      
    riga_from = riga_to + 1
    riga_to   = riga_from
    grid([riga_from,0], [riga_to,5]).bounding_box do write_cell('Vessel', out_ship_name) end
    grid([riga_from,6], [riga_to,7]).bounding_box do write_cell('Voyager n.', out_voyage) end
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
    return "
    Al momento dell’ingresso in deposito del containers venivano constatati danni apparenti alla struttura / corpo dello stesso.\n
    Ad ogni effetto di legge si elevano pertanto, anche a scopo cautelativo, le più ampie riserve sullo stato del containers che vi è stato consegnato per il trasporto in buono stato e privo di alcun danneggiamento o qualsivoglia anomalia.\n
    Ci si riserva , ovviamente, di ispezionare più approfonditamente il container, con l’ausilio di tecnici specializzati, per fornire una più esatta e puntuale descrizione di stima del danno.\n
    Qualora non manifestiate la Vostra disponibilità a far presenziare alle ispezioni in vostro fiduciario, la stima effettuata dal tecnico incaricato verrà considerata come eseguita in contradditorio ed favorevole di entrambi le parti.\n
    L’ammontare del danno vi verrà prontamente girato ed addebitato a mezzo fattura.\n
    La presente vale ad ogni effetto di legge e deve intendersi come riserva formale del danno.\n\n                                                                                                 
                           Firma del trasportatore ( Leggibile )
                           "
    
    
    
    
  end
  
  
  
  
end