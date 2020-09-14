module ShipPreparesHelper
  
  
  
  def ship(c_ship, parameters = {})
    sp = ShipPrepare.find(parameters[:ship_prepare_id]) if !parameters[:ship_prepare_id].nil?
    m_items = []
    baia = {
          xtype: 'panel', border: false, autoScroll: true, scroll: true, scrollable: 'y',
          layout: {type: 'table', columns: 3, aapack: 'start', aaalign: 'stretch'},
          padding: 20, flex: 1,
          defaults: {flex: 1},
          items: bay_rows(c_ship, parameters, nil, nil, nil, sp, true)
        }
        m_items << baia
        
        {
          xtype: 'panel', border: false, scroll: true, scrollable: 'y', autoScroll: true,
          layout: {type: 'hbox', pack: 'start', align: 'stretch'},
          flex: 1, height: '100%', width: '100%',
          items: m_items
       } 
  end
  
  
  
  def bay(c_ship, parameters = {})
    sp = ShipPrepare.find(parameters[:ship_prepare_id]) if !parameters[:ship_prepare_id].nil?
    m_items = []
      
    if parameters[:simula] != 'Y' && !parameters[:gru_id].nil?
      
      if parameters[:options][:spunta]
       #il container lo recuper dalla lista dei container, ordinata per mossa/sequenza
        
       hi = nil
       #container_to_pos = 'UESU4665445'  #ToDo
       #container_to_pos  = 'EMCU5314362'
       #container_to_pos   = 'CPSU4022931' (sembra ok)
       #container_to_pos   = 'MRKU4753388' (sembra ok)
       #container_to_pos   = 'MRKU5576163' (non in terminal)
               
       
       container_to_pos   = sp.find_first_container_to_pos(parameters[:options][:operation_type])
       
        return {
                          xtype: 'panel', border: false,
                          layout: {type: 'vbox', pack: 'start', align: 'stretch'},
                          items: {html: "<h3>Nessun container da posizionare</h3>"},
                          padding: 20,
                          flex: 0.5
                      } if container_to_pos.nil?
       
       #recupero l'id del record sulla lista di imbarco (tra quelle abbinate a ship_prepare)
       import_item = ImportItem.where(container_number: container_to_pos)
                        .where(import_header_id: ShipPrepareItem.select(:import_header_id).where(
                                      ship_prepare_id: parameters[:ship_prepare_id],
                                      item_type: 'LS',
                                      in_out_type: parameters[:options][:operation_type]).pluck(:import_header_id)).first
                                      
       
        return {
                  xtype: 'panel', border: false,
                  layout: {type: 'vbox', pack: 'start', align: 'stretch'},
                  items: {html: "<h3>Container #{container_to_pos} non presente in nessuna lista di imbarco/sbarco abbinata alla lavorazione della nave</h3>"},
                  padding: 20,
                  flex: 0.5
              } if import_item.nil? 
      
      else
        
       #recupero container da posizionare (ultimo movimento di imbarco per la gru)
       hi = sp.find_last_container_by_gru(parameters[:options][:operation_type], parameters)
        
                return {
                   xtype: 'panel', border: false,
                   layout: {type: 'vbox', pack: 'start', align: 'stretch'},
                   items: {html: '<h1>Nessun container da posizionare</h1>'},
                   padding: 20,
                   flex: 0.5
               } if !hi 
              
       container_to_pos = hi.handling_header.container_number
       voyage = hi.voyage
      end
      
      
      
      #ricerco la sua posizione in stiva
      pos = sp.find_container_position(container_to_pos, parameters[:options][:operation_type])
      
      if pos.nil?
        info_container_items = []
        info_container_items << {
                  xtype: 'panel',
                  html: "Container<br><h1>#{container_to_pos}</h1>"
              }
        info_container_items << {xtype: 'panel', html: "Viaggio<br><h2>#{voyage}</h2>"}
        
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
      
      #per la stiva recupero la situazione dei container
      baia_status = sp.get_baia_status(parameters[:options][:operation_type], baia, c_ship)
        
      #lo mostro nella stiva
      informazioni_container = baia_status[pos.to_s][:container_info]
      
      #Info container da posizionare
      info_container_items = []
      info_container_items << {
          xtype: 'panel',
          html: "Container<br><h1>#{container_to_pos}</h1>"
      }
      
      
      
      if parameters[:options][:spunta]
        
        jsonData = {
           rec_id: import_item.id,
           check_form: {
             pier_id: sp.pier_id,
             gru_id:  parameters[:gru_id] 
           }
        }
        
        info_container_items << {
                  xtype: 'button',
                  text: '<h2>Spunta e prosegui</h2>',
                  scale: 'large', cls: 'btn-ok',
                  iconCls: 'fa fa-check-circle fa-3x',
                  handler: lj("
                      function(b){
                  
                        b.mask('Wait ...');
                        
                        Ext.Ajax.request({
                           method: 'POST',
                           url: '#{url_for(:controller=>'import_items', :action=>'set_ok')}',
                           jsonData: #{jsonData.to_json},
                                   success: function(result, request) {
                                      b.unmask();
                                      var jsonData = Ext.JSON.decode(result.responseText);
                                      
                                      if (jsonData.success == true){
                                         //refresh (e mostra prox container da muovere) 
                                         b.up('#main_pos_panel').refresh(b.up('#main_pos_panel'));                             
                                      } else {
                                         alert(jsonData.message);
                                         //per sicurezza eseguo ugualmente un refresh
                                         b.up('#main_pos_panel').refresh(b.up('#main_pos_panel')); 
                                      }                                  
                                   },
                                   failure: function(response, opts) {
                                       b.unmask();
                                       Ext.MessageBox.show({
                                                  title: 'EXCEPTION',
                                                  msg: 'Errore sconosciuto',
                                                  icon: Ext.MessageBox.ERROR,
                                                  buttons: Ext.Msg.OK
                                              })                                                                        
                                   }
              
                        });
                  
                      } //function
                    ")
              }
      end
      
      
      
      if informazioni_container[:weight]
        info_container_items << {
                  xtype: 'panel',
                  html: "<h2>Peso: #{informazioni_container[:weight]}</h2>"
              }
      end
      
      if informazioni_container[:equipment_type]
        info_container_items << {
                  xtype: 'panel',
                  html: "<h2>Tipologia: #{informazioni_container[:equipment_type]}</h2>"
              }
      end

      
        
      #info_container_items << {xtype: 'panel', html: "Viaggio<br><h2>#{voyage}</h2>"}
      info_container_items << {
          xtype: 'panel',
          html: "<h2>Posizione #{pos}</h2>"
      }
      
      
      info_container_items << {
          xtype: 'container', layout: {type: 'hbox', pack: 'start', align: 'stretch'},
          items: [
            {
              xtype: 'button',
              text: 'Chiudi',
              cls: 'btn-close', 
              width: 100, scale: 'large',
              handler: lj("function(){this.up('window').destroy();}")
            }
          ]
      }
      
      info_container_items << {
          xtype: 'container', layout: {type: 'hbox', pack: 'start', align: 'stretch'},
          items: [
            {
              xtype: 'panel', flex: 1,
              html: '<i><span style="font-size: 18px; font-weight: bold">medaT</span> - Simpling.App</i>',
              bodyPadding: '50 0'
            }
          ]
      }
      
      
      
      info_container = {
                 xtype: 'panel', border: false,
                 layout: {type: 'vbox', pack: 'start', align: 'stretch'},
                 items: info_container_items,
                 padding: 20,
                 flex: 0.3                 
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
      defaults: {width: 40, height: 40, border: true},
      items: bay_rows(c_ship, parameters, baia, pos, baia_status, sp)
    }
    m_items << baia
    
    {
      xtype: 'panel', border: false, scroll: true, scrollable: 'y', autoScroll: true,
      layout: {type: 'hbox', pack: 'start', align: 'stretch'},
      items: m_items
   }
  end
  
  
  
  def bay_rows(c_ship, parameters, baia, pos, baia_status, sp, baia_status_autoload = false)
    ret = []
      
    #dalla baia recupero la stiva
    if !baia.nil?
      
      b_height = 700
      b_cell_size = 40
      
      baie = []
      c_ship[:bays].each do |b|
        baie << b if b[:name].include?(baia)
      end
    else
      b_height = 350
      b_cell_size = 20
      baie = c_ship[:bays]
    end  
    
    
    baie.each do |baia_config|
      
      rb = {
                    xtype: 'panel', border: false,
                    height: b_height,
                    padding: 10, flex: 1,
                    layout: {type: 'vbox', pack: 'start', align: 'left'},
                    items: []       
                  }
             
      
      if baia_status_autoload
        baia_status = sp.get_baia_status(parameters[:operation_type], baia_config[:name][0].to_s, c_ship)
      end
      
      #nome baia
      rb[:items] << {
              xtype: 'panel', border: false, height: 40,
              layout: {type: 'hbox', pack: 'center', align: 'left'},
              items: [
                {html: "<center><h2>Baia #{baia_config[:name][2]}</h2></center>", width: b_cell_size.to_i * baia_config[:bay_2][:base].count},
                {html: '', width: b_cell_size},
                {html: "<center><h2>Baia #{baia_config[:name][0]}</h2></center>", width: b_cell_size.to_i * baia_config[:bay_1][:base].count},                     
              ]       
            }
      
      #row intestazione
      rb[:items] << {
        xtype: 'panel', border: false, height: 25,
        layout: {type: 'hbox', pack: 'center', align: 'left'},
        defaults: {width: b_cell_size, height: 25},
        items: bay_cells('HEADER', baia_config, parameters, pos, {}, b_cell_size)       
      }
      
      baia_config[:altezza].each do |a|
        if a == 'separa'
          rb[:items] << {
                      xtype: 'panel', border: false, height: 12,
                      layout: {type: 'hbox', pack: 'center', align: 'left'},
                      defaults: {width: b_cell_size, height: 10},
                      items: []       
                    }
        else
          rb[:items] << {
              xtype: 'panel', border: false,
              layout: {type: 'hbox', pack: 'center', align: 'left'},
              defaults: {width: b_cell_size, height: b_cell_size, border: false},
              items: bay_cells(a, baia_config, parameters, pos, baia_status, b_cell_size)       
            }
        end
      end
    
     ret << rb     
    end    
    
    ret
  end
  
  
  
  def bay_cells(altezza, baia_config, parameters, pos, baia_status, b_cell_size)
   ret = []
   
   #ToDo: evidenziare la cella in base a pos  
   c_style_pos  =  ";background-color: red;" 
   c_style_exec =  ";background-color: green;"
     
     
   #baia 2  (a sx)    
   baia_config[:bay_2][:base].each do |b|
     if baia_config[:bay_2][:ab].nil? || baia_config[:bay_2][:ab]["a#{altezza}"].nil? || baia_config[:bay_2][:ab]["a#{altezza}"].include?(b)
       
       cell_pos    = baia_config[:name][2] + b + altezza
       cell_pos_40 = baia_config[:name][1] + b + altezza

       if !pos.nil? && (cell_pos == pos || cell_pos_40 == pos)
         c_style_add = c_style_pos
       else
         #se e' stato gia' eseguito
         if cell_executed(cell_pos, cell_pos_40, baia_status)
           c_style_add = cell_bg_executed(cell_pos, cell_pos_40, baia_status, c_style_exec)
         else
           c_style_add = ""
         end  
       end
       
       ret << {html: altezza=='HEADER' ? b : cell_text(cell_pos, cell_pos_40, baia_status, 2, b_cell_size), bodyStyle: "background: #{altezza=='HEADER' ? 'white' : '#FCFCFC'}; text-align: center; #{c_style_add}", style: 'border: 1px solid grey'}
     else
       ret << {html: '', border: false} #non presente
     end
   end   
   
   #colonna separazione tra le due baia
   if altezza == 'HEADER'
     ret << {html: '', width: b_cell_size}
   else
     ret << {html: "#{altezza}", width: b_cell_size, style: 'border-top: 1px solid white', 
              bodyStyle: 'font-weight: bold; background: grey; text-align: center; color: white'}   
   end
   
   #baia 1 (a dx)    
   baia_config[:bay_1][:base].each do |b|
     
      cell_pos    = baia_config[:name][0] + b + altezza
      cell_pos_40 = baia_config[:name][1] + b + altezza
 
      if !pos.nil? && (cell_pos == pos || cell_pos_40 == pos)
        c_style_add = c_style_pos
      else
         #se e' stato gia' eseguito
         if cell_executed(cell_pos, cell_pos_40, baia_status)
           c_style_add = cell_bg_executed(cell_pos, cell_pos_40, baia_status, c_style_exec)
         else
           c_style_add = ""
         end
      end

     
     if baia_config[:bay_1][:ab].nil? || baia_config[:bay_1][:ab]["a#{altezza}"].nil? || baia_config[:bay_1][:ab]["a#{altezza}"].include?(b)
       ret << {html: altezza=='HEADER' ? b : cell_text(cell_pos, cell_pos_40, baia_status, 1, b_cell_size), bodyStyle: "background: #{altezza=='HEADER' ? 'white' : '#FCFCFC'}; text-align: center; #{c_style_add}", style: 'border: 1px solid grey'}
     else
       ret << {html: '', border: false} #non presente
     end
   end
    
   ret  
  end
  
  
  def cell_text(cell_pos, cell_pos_40, baia_status, principale_o_secondaria_1_2, b_cell_size)
    if (b_cell_size >= 40)
      hc = '<h2>'
      hc_end = '</h2>'
    else
      hc = ''
      hc_end = ''
    end
    ret = "#{hc}#{cell_text_char(cell_pos, cell_pos_40, baia_status, principale_o_secondaria_1_2)}#{hc_end}"
  end
  
  def cell_text_char(cell_pos, cell_pos_40, baia_status, principale_o_secondaria_1_2)
    return '' if baia_status.nil?
    return 'T' if baia_status[cell_pos.to_s] || (principale_o_secondaria_1_2 == 1 && baia_status[cell_pos_40.to_s])
    return 'X' if (principale_o_secondaria_1_2 == 2 && baia_status[cell_pos_40.to_s])
    return ''
  end
  
  
  def cell_executed(cell_pos, cell_pos_40, baia_status)
    return false if baia_status.nil?
    return true if baia_status[cell_pos.to_s] && baia_status[cell_pos.to_s][:executed]
    return true if (baia_status[cell_pos_40.to_s] && baia_status[cell_pos_40.to_s][:executed])
    return false
  end
  
  
  def cell_bg_executed(cell_pos, cell_pos_40, baia_status, c_style_exec)
    if baia_status[cell_pos.to_s]
      return baia_status[cell_pos.to_s][:container_info][:equipment_style] || c_style_exec  
    end
    if baia_status[cell_pos_40.to_s]
      return baia_status[cell_pos_40.to_s][:container_info][:equipment_style] || c_style_exec  
    end  
  end
  
end