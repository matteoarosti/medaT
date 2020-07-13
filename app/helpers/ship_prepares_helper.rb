module ShipPreparesHelper
  
  
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
        
      info_container_items << {xtype: 'panel', html: "Viaggio<br><h2>#{voyage}</h2>"}
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
      items: bay_rows(c_ship, parameters, baia, pos, baia_status)
    }
    m_items << baia
    
    {
      xtype: 'panel', border: false, scroll: true, scrollable: 'y', autoScroll: true,
      layout: {type: 'hbox', pack: 'start', align: 'stretch'},
      items: m_items
   }
  end
  
  
  
  def bay_rows(c_ship, parameters, baia, pos, baia_status)
    ret = []
      
    #dalla baia recupero la stiva
    if !baia.nil?
      baie = []
      c_ship[:bays].each do |b|
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
                {html: "<center><h1>Baia #{baia_config[:name][2]}</h1></center>", width: 50 * baia_config[:bay_2][:base].count},
                {html: '', width: 40},
                {html: "<center><h1>Baia #{baia_config[:name][0]}</h1></center>", width: 50 * baia_config[:bay_1][:base].count},                     
              ]       
            }
      
      #row intestazione
      ret << {
        xtype: 'panel', border: false, height: 25,
        layout: {type: 'hbox', pack: 'center', align: 'left'},
        defaults: {width: 50, height: 25},
        items: bay_cells('HEADER', baia_config, parameters, pos, {})       
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
              items: bay_cells(a, baia_config, parameters, pos, baia_status)       
            }
        end
      end
    end
    
    ret
  end
  
  
  
  def bay_cells(altezza, baia_config, parameters, pos, baia_status)
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
           c_style_add = c_style_exec;
         else
           c_style_add = "";
         end  
       end
       
       ret << {html: altezza=='HEADER' ? b : cell_text(cell_pos, cell_pos_40, baia_status, 2), bodyStyle: "background: #{altezza=='HEADER' ? 'white' : '#FCFCFC'}; text-align: center; #{c_style_add}", style: 'border: 1px solid grey'}
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
   
   #baia 1 (a dx)    
   baia_config[:bay_1][:base].each do |b|
     
      cell_pos    = baia_config[:name][0] + b + altezza
      cell_pos_40 = baia_config[:name][1] + b + altezza
 
      if !pos.nil? && (cell_pos == pos || cell_pos_40 == pos)
        c_style_add = c_style_pos
      else
         #se e' stato gia' eseguito
         if cell_executed(cell_pos, cell_pos_40, baia_status)
           c_style_add = c_style_exec;
         else
           c_style_add = "";
         end
      end

     
     if baia_config[:bay_1][:ab].nil? || baia_config[:bay_1][:ab]["a#{altezza}"].nil? || baia_config[:bay_1][:ab]["a#{altezza}"].include?(b)
       ret << {html: altezza=='HEADER' ? b : cell_text(cell_pos, cell_pos_40, baia_status, 1), bodyStyle: "background: #{altezza=='HEADER' ? 'white' : '#FCFCFC'}; text-align: center; #{c_style_add}", style: 'border: 1px solid grey'}
     else
       ret << {html: '', border: false} #non presente
     end
   end
    
   ret  
  end
  
  
  def cell_text(cell_pos, cell_pos_40, baia_status, principale_o_secondaria_1_2)
    ret = "<h2>#{cell_text_char(cell_pos, cell_pos_40, baia_status, principale_o_secondaria_1_2)}</h2>"
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
  
end