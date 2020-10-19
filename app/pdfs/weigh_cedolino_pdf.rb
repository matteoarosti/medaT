class WeighCedolinoPdf < Prawn::Document
  
  
  def initialize(default_prawn_options={})
    
      #A5, orizzontale
      default_prawn_options[:page_size] = 'A4'
      default_prawn_options[:page_layout] = :portrait
        
      super(default_prawn_options)
      font_size 6
   end

  
  def draw(item_weigh)
    define_grid(:columns => 11, :rows => 52, :gutter => 0)
    
    prepare_data(item_weigh)

    
    repeat(:all) do  
      draw_text "medaT - Terminsal Service Software", :at => [0, 0], :size => 4
      riga_from = 0
      riga_to   = 1
      grid([riga_from, 0], [riga_to, 10]).bounding_box do
        text "Cedolino", :size => 12      
      end
      
      #intestazione
      riga_from = riga_to + 2
      riga_to   = riga_from + 4    
      ar_delivered_by = ['I.CO.P. s.rl.', 'Via L.go Mare Vanvitelli, 68', '60121 - Ancona', 'Italia']
      #ar_delivered_to = [docH.customer.name, docH.customer.address.to_s]
      grid([riga_from,0], [riga_to,4]).bounding_box do write_cell_ar('Mittente',      ar_delivered_by, 8) end
      #grid([riga_from,6], [riga_to,10]).bounding_box do write_cell_ar('Destinatario', ar_delivered_to, 8) end
        
      image "#{Rails.root}/app/assets/images/customer-logo.jpg", :position => :right, :vposition => 50, :width => 120   
        
    end

    
    #riga 0
    riga_to = 8
    
    
    riga_from = riga_to + 2
    riga_to   = riga_from 


    #DATI PESA ------------------------------------------    
    grid([riga_from, 1], [riga_to,  6]).bounding_box do text "DATI PESA", :size => 16 end
    draw_h_line
    
    peso_tara = @data['TARA'][:ev_data][:weigh].to_i
    
    riga_from = riga_to + 2
    riga_to   = riga_from      
    grid([riga_from, 1], [riga_to, 10]).bounding_box do text TabConfig.get_notes('WEIGH', 'PESA_I').to_s, :size => 12 end     
      
    riga_from = riga_to + 2
    riga_to   = riga_from      
    grid([riga_from, 1], [riga_to,  6]).bounding_box do text "Scadenza", :size => 12 end     
    grid([riga_from, 7], [riga_to, 10]).bounding_box do text TabConfig.get_notes('WEIGH', 'PESA_S').to_s, :size => 12 end
    
    
    
    #TARA ------------------------------------------    
	riga_from = riga_to + 3
    riga_to   = riga_from  
    grid([riga_from, 1], [riga_to,  6]).bounding_box do text "TARA", :size => 16 end
    draw_h_line
    
    peso_tara = @data['TARA'][:ev_data][:weigh].to_i
    
    riga_from = riga_to + 2
    riga_to   = riga_from      
    grid([riga_from, 1], [riga_to,  6]).bounding_box do text "Data", :size => 12 end     
    grid([riga_from, 7], [riga_to, 10]).bounding_box do text @data['TARA'][:ev].created_at.strftime("%d/%m/%y %H:%M"), :size => 12 end
      
    riga_from = riga_to + 2
    riga_to   = riga_from      
    grid([riga_from, 1], [riga_to,  6]).bounding_box do text "Peso", :size => 12 end     
    grid([riga_from, 7], [riga_to, 10]).bounding_box do text "KG " + @data['TARA'][:ev_data][:weigh].to_s, :size => 12 end
    

      
    #PESO LORDO ------------------------------------------
    peso_lordo = @data['LORDO'][:ev_data][:weigh].to_i
    riga_from = riga_to + 4
    riga_to   = riga_from 

    grid([riga_from, 1], [riga_to,  6]).bounding_box do text "PESO LORDO", :size => 16 end
    draw_h_line
          
    riga_from = riga_to + 2
    riga_to   = riga_from      
    grid([riga_from, 1], [riga_to,  6]).bounding_box do text "Data", :size => 12 end     
    grid([riga_from, 7], [riga_to, 10]).bounding_box do text @data['LORDO'][:ev].created_at.strftime("%d/%m/%y %H:%M"), :size => 12 end
      
    riga_from = riga_to + 2
    riga_to   = riga_from      
    grid([riga_from, 1], [riga_to,  6]).bounding_box do text "Peso", :size => 12 end     
    grid([riga_from, 7], [riga_to, 10]).bounding_box do text "KG " + @data['LORDO'][:ev_data][:weigh].to_s, :size => 12 end
    


  
    #PESO NETTO ------------------------------------------
    peso_netto = peso_lordo - peso_tara
    riga_from = riga_to + 4
    riga_to   = riga_from 
    
    grid([riga_from, 1], [riga_to,  6]).bounding_box do text "PESO NETTO", :size => 16 end
    draw_h_line
        
    riga_from = riga_to + 2
    riga_to   = riga_from      
    grid([riga_from, 1], [riga_to,  6]).bounding_box do text "Peso", :size => 12 end     
    grid([riga_from, 7], [riga_to, 10]).bounding_box do text "KG " + peso_netto.to_s, :size => 12 end
    
          
      
      
    #Dati aggiuntivo (container, booking)
    riga_from = riga_to + 4
    riga_to   = riga_from 
    
    grid([riga_from, 1], [riga_to,  6]).bounding_box do text "Riferimenti", :size => 16 end
    draw_h_line
      
    riga_from = riga_to + 2
    riga_to   = riga_from      
    grid([riga_from, 1], [riga_to,  4]).bounding_box do text "Autista", :size => 12 end     
    grid([riga_from, 5], [riga_to, 10]).bounding_box do text @data['driver'].to_s, :size => 12 end
        
    riga_from = riga_to + 1
    riga_to   = riga_from      
    grid([riga_from, 1], [riga_to,  4]).bounding_box do text "Container", :size => 12 end     
    grid([riga_from, 5], [riga_to, 10]).bounding_box do text @data['container'].to_s, :size => 12 end
      

    riga_from = riga_to + 1
    riga_to   = riga_from      
    grid([riga_from, 1], [riga_to,  4]).bounding_box do text "Booking", :size => 12 end     
    grid([riga_from, 5], [riga_to, 10]).bounding_box do text @data['booking'].to_s, :size => 12 end
  
      
      

  #page numbers
  string = "page <page> of <total>" 
  options = { 
    :at => [bounds.right - 150, bounds.top],            
    :width => 150,            
    :align => :right}
  number_pages string, options
  

    
  end #draw
  
  
  
  def prepare_data(item_weigh)
    @data = {}
    @data['item'] = item_weigh
      
    if !item_weigh.handling_item.nil?
      #pesa su movimento terminal
      @data['driver'] = item_weigh.handling_item.driver
      @data['container'] = item_weigh.handling_item.handling_header.container_number
      @data['booking'] = item_weigh.handling_item.handling_header.num_booking
    else
      #pesa su richiesta cliente
      @data['driver']     = item_weigh.driver
      @data['container']  = item_weigh.container_number
      @data['booking']    = item_weigh.booking_customer              
    end
        
      
    item_events = LogEvent.all_for(item_weigh)
    item_events.each do |i|
         
         jp = (ActiveSupport::JSON.decode i.notes).with_indifferent_access
         
         r = {}
         case i.operation
           when 'LORDO'
              @data['LORDO'] = {ev: i, ev_data: jp}
           when 'TARA'
              @data['TARA'] = {ev: i, ev_data: jp}
         end
    end   
  end
  
  
  def pesi
    {
      tara: @data['TARA'][:ev_data][:weigh].to_i,
      lordo: @data['LORDO'][:ev_data][:weigh].to_i,
      netto: @data['LORDO'][:ev_data][:weigh].to_i - @data['TARA'][:ev_data][:weigh].to_i
    }
  end
  
  
  
  
  
  #################################################
  # UTILITY
  #################################################
  
  def draw_h_line
    stroke do
          #move_up 15
          stroke_color 'c0c0c0'
          dash(5, space: 2, phase: 0)
          line_width 1
          stroke_horizontal_rule
        end
  end
  

  def write_cell_ar_container(title, content)
    line_width 0.5
    move_down 3
    indent(3) do
      text title, :size => 12
      move_down 4
      content.each do |c|
        text c, :size => 7
      end
    end
    stroke_bounds #bordo
  end

    
  def write_cell_ar_no_title(content, size = 7)
    line_width 0.5
    move_down 2
    indent(3) do
      content.each do |c|
        text c, :size => size
      end
    end
    stroke_bounds #bordo
  end
  
  
  def write_cell_ar(title, content, size = 7)
    line_width 0.5
    move_down 5
    indent(3) do
      text title #, :style=>'bold'
      move_down 4            
      content.each do |c|
        text c, :size => size
      end
    end
    stroke_bounds #bordo
  end

    
end