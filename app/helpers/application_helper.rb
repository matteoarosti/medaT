module ApplicationHelper

 def extjs_std_combo(name, item, p = {}, attr = {})

  input_name = p[:input_name] || name
  value = item.send(name) || p[:value]
 
  if p[:displayField].nil?
    p[:valueField] = 'cod'
    p[:displayField] = 'descr'
  else
    p[:valueField] = p[:valueField] || p[:displayField]
  end
  
  add_attr = extsj_create_attr_str(attr)
  
  ret = "
    {
      xtype: 'combobox', name: #{input_name.to_json}, value: #{value.to_json}, 
      fieldLabel: #{(p[:fieldLabel] || name.humanize).to_json},
      displayField: #{p[:displayField].to_json},
      valueField: #{p[:valueField].to_json || p[:displayField].to_json},
      forceSelection: true,
      allowBlank: #{p[:allowBlank] || false},
      triggerAction: 'all',
      typeAhead: true,
      queryMode: 'local',
      lastQuery: '',  
      store: #{p[:store]},
      listeners: {#{p[:listeners]}}
      #{add_attr}
    }
    "
  return ret 
 end


 
  def extjs_std_combo_bind(name, item, p = {}, attr = {})
  
   field_name = p[:field_name] || name + '_id'
   if p[:displayField].nil?
     p[:valueField] = 'cod'
     p[:displayField] = 'descr'
   else
     p[:valueField] = p[:valueField] || p[:displayField]
   end
   
   add_attr = extsj_create_attr_str(attr)
   
   ret = "
     {
       xtype: 'combobox', 
       fieldLabel: #{name.humanize.to_json},
       displayField: #{p[:displayField].to_json},
       valueField: #{p[:valueField].to_json || p[:displayField].to_json},
       forceSelection: true,
       allowBlank: #{p[:allowBlank] || false},
       triggerAction: 'all',
       typeAhead: true,
       queryMode: 'local',
       lastQuery: '',  
       store: #{p[:store]},
       bind: \"{rec.#{field_name}}\",
       listeners: {#{p[:listeners]}}
       #{add_attr}
     }
     "
   return ret 
  end

 
 
 def extjs_std_combo_model(name, item, p = {}, attr = {})
  field_name = name + '_id'
  input_name = p[:input_name] || (p[:input_prefix].to_s + name + '_id')    
  model_class = name.camelize.constantize

  add_attr = extsj_create_attr_str(attr)
  
  ret = "
    {
      xtype: 'combobox', name: #{input_name.to_json}, value: #{item.send(field_name).to_json},
      fieldLabel: #{(p[:fieldLabel] || name.humanize).to_json},
      displayField: #{model_class.combo_displayField.to_json},
      valueField: 'id',
      forceSelection: true,
      allowBlank: #{p[:allowBlank] || false},
      triggerAction: 'all',
      typeAhead: true,
      queryMode: 'local',
      lastQuery: '',  
      store: #{p[:store] || extjs_std_store_model(name)},
      listeners: {#{p[:listeners]}}
      #{add_attr}
    }
    "
  return ret 
 end

 
  def extjs_std_combo_model_bind(name, item, p = {}, attr = {})
   field_name = name + '_id'
   model_class = name.camelize.constantize
 
   add_attr = extsj_create_attr_str(attr)
   
   ret = "
     {
       xtype: 'combobox',  
       fieldLabel: #{name.humanize.to_json},
       displayField: #{model_class.combo_displayField.to_json},
       valueField: 'id',
       forceSelection: true,
       allowBlank: #{p[:allowBlank] || false},
       triggerAction: 'all',
       typeAhead: true,
       queryMode: 'local',
       lastQuery: '',  
       store: #{p[:store] || extjs_std_store_model(name)},
       bind: \"{rec.#{field_name}}\",
       listeners: {#{p[:listeners]}}
       #{add_attr}
     }
     "
   return ret 
  end

 
 
 
  
 
 def extsj_create_attr_str(attrs)
  return '' if attrs.empty?
  rets = []
  attrs.each do |kattr, attr|
   rets<< "#{kattr}: #{attr.to_json}"
  end
  return ", " + rets.join(",")
 end
 
 def extjs_std_textfield(name, item, p = {}, attr = {})
  input_name = p[:input_name] || p[:input_prefix].to_s + name
  add_attr = extsj_create_attr_str(attr)
  ret = "{xtype: 'textfield', fieldLabel: #{(p[:fieldLabel] || name.humanize).to_json}, name: #{input_name.to_json}, value: #{item.send(name).to_json}, maxLength: #{item.class.columns_hash[name].limit}, allowBlank: #{p[:allowBlank] || false} #{add_attr}}" 
 end

  def extjs_std_numberfield(name, item, p = {}, attr = {})
   input_name = p[:input_name] || p[:input_prefix].to_s + name
   add_attr = extsj_create_attr_str(attr)
   ret = "{xtype: 'numberfield', fieldLabel: #{name.humanize.to_json}, name: #{input_name.to_json}, value: #{item.send(name).to_json}, maxLength: #{item.class.columns_hash[name].limit}, allowBlank: #{p[:allowBlank] || false} #{add_attr}}" 
  end

  def extjs_std_numberfield_bind(name, item, p = {}, attr = {})
   input_name = p[:input_name] || p[:input_prefix].to_s + name
   add_attr = extsj_create_attr_str(attr)
   ret = "{xtype: 'numberfield', bind: \"{rec.#{name}}\", fieldLabel: #{name.humanize.to_json}, allowBlank: #{p[:allowBlank] || false} #{add_attr}}" 
  end
 
  
 def extjs_std_datefield(name, item, p = {}, attr = {})
  add_attr = extsj_create_attr_str(attr) 
  ret = "{xtype: 'datefield', fieldLabel: #{(p[:fieldLabel] || name.humanize).to_json}, name: #{(p[:name] || name).to_json}, value: #{item.send(name).to_json}, allowBlank: #{p[:allowBlank] || false} #{add_attr}}" 
 end
 
 def extjs_std_timefield(name, item) 
  ret = "{xtype: 'timefield', fieldLabel: #{name.humanize.to_json}, name: #{name.to_json}, value: #{item.send(name).to_json}, allowBlank: false}" 
 end
   
 def extjs_std_hiddenfield(name, item) 
  ret = "{xtype: 'hiddenfield', name: #{name.to_json}, value: #{item.send(name).to_json}}" 
 end
 
 def extjs_std_booleanfield(name, item, p = {}, attr = {})
  input_name = p[:input_name] || p[:input_prefix].to_s + name    
  add_attr = extsj_create_attr_str(attr)
  ret = "{xtype: 'checkbox', name: #{input_name.to_json}, value: #{item.send(name).to_json}, fieldLabel: #{(p[:fieldLabel] || name.humanize).to_json}, 
   inputValue: true,
   uncheckedValue: false  #{add_attr} }" 
 end

 def extjs_std_textareafield(name, item, p = {}, attr = {})
  add_attr = extsj_create_attr_str(attr)
  ret = "{xtype: 'textareafield', name: #{name.to_json}, value: #{item.send(name).to_json}, fieldLabel: #{(p[:fieldLabel] || name.humanize).to_json}, anchor: '100%', grow: true #{add_attr} }"
 end

 def extjs_std_datetimefield(name, item, p = {}) 
  name_date = name + "_date"
  name_time = name + "_time"
  ret = "
            {
                xtype: 'fieldcontainer',
                fieldLabel: #{name.humanize.to_json},
                combineErrors: true,
                msgTarget : 'side',
                layout: 'hbox',
                defaults: {
                    flex: 1,
                    hideLabel: true
                },                
                items: ["  
  ret += " {xtype: 'datefield', name: #{name_date.to_json}, value: #{set_date_value(item.send(name)).to_json}, allowBlank: #{p[:allowBlank] || false}}"
  ret += ",{xtype: 'timefield', name: #{name_time.to_json}, value: #{set_time_value(item.send(name)).to_json}, allowBlank: #{p[:allowBlank] || false}}"  
  ret += "]}" 
 end

 
 def set_date_value(v)
   if !v.nil?
     return v.to_date
   end
  return nil 
 end
 
  def set_time_value(v)
     if !v.nil?
       return v.to_s(:time)
     end
    return nil 
   end
   
 

 def extjs_std_store_model(model)
  ret = "Ext.create('Ext.data.Store', {
          model: #{model.camelize.to_json},
          autoLoad: true,
          proxy: {
              type: 'ajax',
              url: '#{root_path}#{model.pluralize}/get_combo_data',              
              reader: {
                  type: 'json',
                  rootProperty: 'items'                  
              }       
          },          
      })"
  return ret    
 end 
 
 def extjs_std_store_url(url)
  ret = "Ext.create('Ext.data.Store', {
          fields: [],
          autoLoad: true,
          proxy: {
              type: 'ajax',
              url: #{url.to_json},              
              reader: {
                  type: 'json',
                  rootProperty: 'items'
              }       
          },          
      })"
  return ret    
 end 
 
 def extjs_std_store_data(data)
  ret = "Ext.create('Ext.data.Store', {
          fields: [],
          data: #{data.to_json}          
      })"
  return ret    
 end 
     
 
 def extjs_fieldcontainer(label, p = {}, items = [])
   ret = "
      {
         xtype: 'fieldcontainer',
         fieldLabel: #{label.to_json},
         combineErrors: true,
         msgTarget : 'side',
         layout: '#{p[:layout] || "hbox"}',
         anchor: '100%',
         defaults: {xtype: 'textfield', flex: 1, hideLabel: #{(p[:hideLabel] || false).to_json}},
         items: [
          " + items.join(', ') + "
         ]
   }    
   "
 end
 
 
 
 def extjs_notes(label, hh, hi, p={})
   ret = ""
   ret += "{xtype: 'tbfill'}, " unless p[:tbfill] == "N"
   
   ar_note_field = []
   ar_note_field << extjs_std_textareafield('notes',  hi, {:fieldLabel => "Note"}, {:width => "100%"})
   ar_note_field << extjs_std_textareafield('notes_int',  hi, {:fieldLabel => "Note interne"}, {:width => "100%"})  unless !User.current.can?(:handling_header, :notes_int)
  
     
     ret += extjs_fieldcontainer('', {:layout=>"vbox"}, ar_note_field)
   

 end
 
 
 def extjs_driver_plate(label, hi, p = {})  
   ret = ""
   
   ar_note_field = []
   ar_note_field << "{xtype: 'textfield', name: 'driver', fieldLabel: 'Driver', maxLength: 50}"
   ar_note_field << "{xtype: 'textfield', labelAlign: 'right', name: 'plate', fieldLabel: 'Targa', maxLength: 15}"
     
   ret += extjs_fieldcontainer('', {:layout=>"hbox"}, ar_note_field)  
 end

 
 
 def extjs_posizionamento(label, hh, hi, p = {})     
  #TODO: serve gestirlo meglio?   
  hh.fila   = nil
  hh.blocco = nil
  hh.tiro   = nil
  hh.pier   = nil 
  
  allowBlank = p[:allowBlank]
  allowBlank = true if allowBlank.to_s.empty? 
        
 #posizionamento
   ret = "
   {
         xtype: 'fieldset',
         title: 'Posizionamento',
         layout: 'anchor',
         items: [
         
     {
               xtype: 'fieldcontainer',
               combineErrors: true,
               msgTarget : 'side',
               layout: 'hbox',
               anchor: '100%',
               defaults: {xtype: 'textfield', width: 90, hideLabel: false, labelWidth: 40, labelAlign: 'right'},
               items: [                 
                    #{extjs_std_textfield('fila', hh, :allowBlank => allowBlank, :input_prefix => 'hh_')},
                    #{extjs_std_textfield('blocco', hh, :allowBlank => allowBlank, :input_prefix => 'hh_')},
                    #{extjs_std_textfield('tiro', hh, :allowBlank => allowBlank, :input_prefix => 'hh_')},
                    #{extjs_std_combo_model('pier', hh, {:allowBlank => allowBlank, :input_prefix => 'hh_', :fieldLabel => 'Banchina'}, {:flex => 1, :labelWidth => 90})}  
           ]
       }
     ]
   }           
  "
end
 

  def extjs_to_be_moved(label, hh, hi)   
   #TODO: serve gestire un default o lo imposto sempre a true?
   hi.to_be_moved = true  
    
    ret = "
    {
          xtype: 'fieldset',
          title: 'Da movimentare (segnala al mulettista)',
          layout: 'anchor',
          items: [
          
      {
                xtype: 'fieldcontainer',
                combineErrors: true,
                msgTarget : 'side',
                layout: 'hbox',
                anchor: '100%',
                defaults: {xtype: 'textfield', flex: 1, hideLabel: false, labelWidth: 100, labelAlign: 'right'},
                items: [                 
                     #{extjs_std_booleanfield('to_be_moved', hi, :allowBlank => true)},
            ]
        }
      ]
    }           
   "
 end

 
 

  def extjs_info_booking(hh, hi)     
    
  #posizionamento
    ret = "
    {
          xtype: 'fieldset',
          title: 'Info Booking',
          layout: 'anchor',
          items: [
          
      {
                xtype: 'fieldcontainer',
                combineErrors: true,
                msgTarget : 'side',
                layout: 'hbox',
                anchor: '100%',
                defaults: {xtype: 'textfield', disabled: true, flex: 1, hideLabel: false, labelWidth: 100},
                items: [                     
                     {fieldLabel: 'Numero', value: #{hh.num_booking.to_json},     labelWidth: 70},
                     {fieldLabel: 'Nave', value: #{(!hh.booking.nil? ? hh.booking.ship.name : '').to_json}, labelWidth: 70, labelAlign: 'right'},
                     {fieldLabel: 'Viaggio', value: #{(!hh.booking.nil? ? hh.booking.voyage : '').to_json}, labelWidth: 70, labelAlign: 'right'},
            ]
        }
      ]
    }           
   "
 end

 
  
 
 
 
 #aggiungi attributi per un oggetto centrale
 def fcC(attr = {})
   attr[:labelAlign] = 'right'
   attr[:padding] = '0 10 0 0'
   attr
 end
 
  #aggiungi attributi per un oggetto finale
  def fcR(attr = {})
    attr[:labelAlign] = 'right'
    attr[:padding] = '0 0 0 0'
    attr
  end 
 
      
end
