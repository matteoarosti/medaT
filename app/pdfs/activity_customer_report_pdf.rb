class ActivityCustomerReportPdf < Prawn::Document
  
  
  def initialize(default_prawn_options={})
    
      #A5, orizzontale
      default_prawn_options[:page_size] = 'A4'
      default_prawn_options[:page_layout] = :portrait
        
      super(default_prawn_options)
      font_size 6
   end

  
  def draw(docH)
    define_grid(:columns => 11, :rows => 52, :gutter => 0)
    

    
    repeat(:all) do  
      draw_text "medaT - Terminsal Software", :at => [0, 0], :size => 4
      riga_from = 0
      riga_to   = 1
      grid([riga_from, 0], [riga_to, 10]).bounding_box do
        text "Documento Registrazione Attività: N. #{docH.nr_seq}/#{docH.nr_anno} del #{docH.d_reg.strftime("%d/%m/%Y")}", :size => 12      
      end
      
      #intestazione
      riga_from = riga_to + 2
      riga_to   = riga_from + 4    
      ar_delivered_by = ['I.CO.P. s.rl.', 'Via L.go Mare Vanvitelli, 68', '60121 - Ancona', 'Italia']
      ar_delivered_to = [docH.customer.name, docH.customer.address.to_s]
      grid([riga_from,0], [riga_to,4]).bounding_box do write_cell_ar('Mittente',      ar_delivered_by, 8) end
      grid([riga_from,6], [riga_to,10]).bounding_box do write_cell_ar('Destinatario', ar_delivered_to, 8) end
        
    end

    
    #riga 0
    riga_to = 8
    
    
    riga_from = riga_to + 2
    riga_to   = riga_from 
    
    #TH
    grid([riga_from, 0], [riga_to, 2]).bounding_box do write_cell_ar_no_title(['Container']) end      
    grid([riga_from, 3], [riga_to, 8]).bounding_box do write_cell_ar_no_title(['Operazione']) end
    grid([riga_from, 9], [riga_to, 9]).bounding_box do write_cell_ar_no_title(['Eseguita il']) end
    grid([riga_from,10], [riga_to,10]).bounding_box do write_cell_ar_no_title(['Confermata il']) end

    #elenco attività (DETT_CONTAINERS)
    ActivityDettContainer.where(doc_h_notifica_id: docH.id).each do |rec|
      
      if riga_to >= 50
        start_new_page
        riga_to = 8
      end
      
      riga_from = riga_to + 1
      riga_to   = riga_from + 1
      
      grid([riga_from, 0], [riga_to, 2]).bounding_box do write_cell_ar_container(rec.container_number, [rec.activity.shipowner.name]) end      
      grid([riga_from, 3], [riga_to, 8]).bounding_box do write_cell_ar_no_title([rec.activity.activity_op.name]) end
      grid([riga_from, 9], [riga_to, 9]).bounding_box do write_cell_ar_no_title([rec.execution_at ? rec.execution_at.strftime("%d/%m/%y %H:%M") : '']) end
      grid([riga_from,10], [riga_to,10]).bounding_box do write_cell_ar_no_title([rec.confirmed_at ? rec.confirmed_at.strftime("%d/%m/%y %H:%M") : '']) end     
    end
    

    
    #elenco attività (ACTIVITIES - no CUST_INSPECTION)
    Activity.where(doc_h_notifica_id: docH.id).each do |rec|
      
      if riga_to >= 50
        start_new_page
        riga_to = 8
      end
      
      riga_from = riga_to + 1
      riga_to   = riga_from + 1
      
      grid([riga_from, 0], [riga_to, 2]).bounding_box do write_cell_ar_container('-', ['-']) end      
      grid([riga_from, 3], [riga_to, 8]).bounding_box do write_cell_ar_no_title([!rec.activity_op.nil? ? rec.activity_op.name : '']) end
      grid([riga_from, 9], [riga_to, 9]).bounding_box do write_cell_ar_no_title([rec.execution_at ? rec.execution_at.strftime("%d/%m/%y %H:%M") : '']) end
      grid([riga_from,10], [riga_to,10]).bounding_box do write_cell_ar_no_title(['']) end     
    end
    
    
      riga_from = riga_to + 2
      riga_to   = riga_from + 1
      grid([riga_from, 0], [riga_to, 10]).bounding_box do
        text "Si prega di far pervenire eventuali contestazioni entro 2 gg dalla presenta alla email fatturazione@icopsrl.net", :size => 7      
      end




  #page numbers
  string = "page <page> of <total>" 
  options = { 
    :at => [bounds.right - 150, bounds.top],            
    :width => 150,            
    :align => :right}
  number_pages string, options
  

    
  end #draw
  
  
  
  
  
  #################################################
  # UTILITY
  #################################################

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