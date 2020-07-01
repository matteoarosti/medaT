module ShipPreparesHelper
  
  
  def bay(c_ship, parameters = {})
    
    m_items = []

      
    if parameters[:simula] != 'Y' && !parameters[:gru_id].nil?
      
      #recupero container da posizionare (ultimo movimento di imbarco per la gru)
      hi = HandlingItem.where(handling_item_type: 'O_LOAD', gru_id: parameters[:gru_id]).order("id desc").first
      
      if !hi
        return {
           xtype: 'panel', border: false,
           layout: {type: 'vbox', pack: 'start', align: 'stretch'},
           items: {html: '<h1>Nessun container da posizionare</h1>'},
           padding: 20,
           flex: 0.5
       } 
      end  
      
      
      container_to_pos = hi.handling_header.container_number
      
      #ricerco la sua posizione in stiva
      sp = ShipPrepare.find(parameters[:ship_prepare_id])
      pos = sp.find_container_position(container_to_pos)
      
      if pos.nil?
        info_container_items = []
        info_container_items << {
                  xtype: 'panel',
                  html: "Container<br><h1>#{container_to_pos}</h1>"
              }
        info_container_items << {xtype: 'panel', html: "Viaggio<br><h2>#{hi.voyage}</h2>"}
        info_container_items << {
                          xtype: 'panel',
                          html: "<h1><FONT COLOR=RED>POSIZIONE NON TROVATA SU NAVE</FONT></h1>"
                      }
        info_container = {
                         xtype: 'panel', border: false,
                         layout: {type: 'vbox', pack: 'start', align: 'stretch'},
                         items: info_container_items,
                         padding: 20,
                         flex: 0.5
                       }              
        return info_container
      end
      
      
      #la posizione e' del tipo 090402
      baia = pos[0,2]
      
      #lo mostro nella stiva
      
      info_container_items = []
      info_container_items << {
          xtype: 'panel',
          html: "Container<br><h1>#{container_to_pos}</h1>"
      }
      info_container_items << {xtype: 'panel', html: "Viaggio<br><h2>#{hi.voyage}</h2>"}
      info_container_items << {
          xtype: 'panel',
          html: "<h2>Posizione #{pos}</h2>"
      }
      
      info_container = {
                 xtype: 'panel', border: false,
                 layout: {type: 'vbox', pack: 'start', align: 'stretch'},
                 items: info_container_items,
                 padding: 20,
                 flex: 0.5
               }
                
      m_items << info_container
    else
      pos  = nil
      baia = nil         
    end      
      
      
    baia = {
      xtype: 'panel', border: false, autoScroll: true, scroll: true, scrollable: 'y',
      layout: {type: 'vbox', pack: 'start', align: 'stretch'},
      padding: 20, flex: 1,
      defaults: {width: 50, height: 50, border: true},
      items: bay_rows(c_ship, parameters, baia, pos)
    }
    m_items << baia
    
    {
      xtype: 'panel', border: false, scroll: true, scrollable: 'y', autoScroll: true,
      layout: {type: 'hbox', pack: 'start', align: 'stretch'},
      items: m_items
   }
  end
  
  
  
  def bay_rows(c_ship, parameters, baia, pos)
    ret = []
      
    #dalla baia recupero la stiva
    if !baia.nil?
      baie = []
      c_ship[:bays].each do |b|
        puts "baia: #{baia}"
        baie << b if b[:name].include?(baia)
      end
    else
      baie = c_ship[:bays]
    end  
    
    
    baie.each do |baia_config|
      
      #nome baia
      ret << {
              xtype: 'panel', border: false,
              layout: {type: 'hbox', pack: 'center', align: 'left'},
              items: [
                {html: "<center><h1>Baia #{baia_config[:name][0]}</h1></center>", width: 50 * baia_config[:bay_1][:base].count},
                {html: '', width: 40},
                {html: "<center><h1>Baia #{baia_config[:name][2]}</h1></center>", width: 50 * baia_config[:bay_2][:base].count},                     
              ]       
            }
      
      #row intestazione
      ret << {
        xtype: 'panel', border: false, height: 25,
        layout: {type: 'hbox', pack: 'center', align: 'left'},
        defaults: {width: 50, height: 25},
        items: bay_cells('HEADER', baia_config, parameters, pos)       
      }
      
      baia_config[:altezza].each do |a|
        if a == 'separa'
          ret << {
                      xtype: 'panel', border: false, height: 12,
                      layout: {type: 'hbox', pack: 'center', align: 'left'},
                      defaults: {width: 50, height: 10},
                      items: []       
                    }
        else
        ret << {
              xtype: 'panel', border: false,
              layout: {type: 'hbox', pack: 'center', align: 'left'},
              defaults: {width: 50, height: 50, border: false},
              items: bay_cells(a, baia_config, parameters, pos)       
            }
        end
      end
    end
    
    ret
  end
  
  
  
  def bay_cells(altezza, baia_config, parameters, pos)
   ret = []
   
   #ToDo: evidenziare la cella in base a pos  
   c_style_pos =  ";background-color: red;" 
     
     
   #baia 1    
   baia_config[:bay_1][:base].each do |b|
     if baia_config[:bay_1][:ab].nil? || baia_config[:bay_1][:ab]["a#{altezza}"].nil? || baia_config[:bay_1][:ab]["a#{altezza}"].include?(b)
       
       cell_pos    = baia_config[:name][0] + b + altezza
       cell_pos_40 = baia_config[:name][1] + b + altezza

       if !pos.nil? && (cell_pos == pos || cell_pos_40 == pos)
         c_style_add = c_style_pos
       else
         c_style_add = "";
       end
       
       ret << {html: altezza=='HEADER' ? b : '', bodyStyle: "background: #{altezza=='HEADER' ? 'white' : '#FCFCFC'}; text-align: center; #{c_style_add}", style: 'border: 1px solid grey'}
     else
       ret << {html: '', border: false} #non presente
     end
   end   
   
   #colonna separazione tra le due baia
   if altezza == 'HEADER'
     ret << {html: '', width: 40}
   else
     ret << {html: "<br>#{altezza}", width: 40, style: 'border-top: 1px solid white', bodyStyle: 'font-weight: bold; background: grey; text-align: center; color: white'}   
   end
   
   #baia 2    
   baia_config[:bay_2][:base].each do |b|
     
      cell_pos    = baia_config[:name][2] + b + altezza
      cell_pos_40 = baia_config[:name][1] + b + altezza
 
      if !pos.nil? && (cell_pos == pos || cell_pos_40 == pos)
          c_style_add = c_style_pos
        else
          c_style_add = "";
      end

     
     if baia_config[:bay_2][:ab].nil? || baia_config[:bay_2][:ab]["a#{altezza}"].nil? || baia_config[:bay_2][:ab]["a#{altezza}"].include?(b)
       ret << {html: altezza=='HEADER' ? b : '', bodyStyle: "background: #{altezza=='HEADER' ? 'white' : '#FCFCFC'}; text-align: center; #{c_style_add}", style: 'border: 1px solid grey'}
     else
       ret << {html: '', border: false} #non presente
     end
   end
    
   ret  
  end
  
end