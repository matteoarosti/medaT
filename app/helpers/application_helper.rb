module ApplicationHelper

 def extjs_std_combo(name, item, p = {}, attr = {})
 
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
      xtype: 'combobox', name: #{name.to_json}, value: #{value.to_json}, 
      fieldLabel: #{name.humanize.to_json},
      displayField: #{p[:displayField].to_json},
      valueField: #{p[:valueField].to_json || p[:displayField].to_json},
      forceSelection: true,
      allowBlank: #{p[:allowBlank] || false},
      triggerAction: 'all',  
      store: #{p[:store]},
      listeners: {#{p[:listeners]}}
      #{add_attr}
    }
    "
  return ret 
 end


 def extjs_std_combo_model(name, item, p = {}, attr = {})
  field_name = name + '_id'
  model_class = name.camelize.constantize

  add_attr = extsj_create_attr_str(attr)
  
  ret = "
    {
      xtype: 'combobox', name: #{field_name.to_json}, value: #{item.send(field_name).to_json}, 
      fieldLabel: #{name.humanize.to_json},
      displayField: #{model_class.combo_displayField.to_json},
      valueField: 'id',
      forceSelection: true,
      allowBlank: #{p[:allowBlank] || false},
      triggerAction: 'all',  
      store: #{p[:store] || extjs_std_store_model(name)},
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
  ret = "{xtype: 'textfield', fieldLabel: #{name.humanize.to_json}, name: #{input_name.to_json}, value: #{item.send(name).to_json}, maxLength: #{item.class.columns_hash[name].limit}, allowBlank: #{p[:allowBlank] || false} #{add_attr}}" 
 end
 
 def extjs_std_datefield(name, item, p = {}) 
  ret = "{xtype: 'datefield', fieldLabel: #{(p[:fieldLabel] || name.humanize).to_json}, name: #{(p[:name] || name).to_json}, value: #{item.send(name).to_json}, allowBlank: #{p[:allowBlank] || false}}" 
 end
 
 def extjs_std_timefield(name, item) 
  ret = "{xtype: 'timefield', fieldLabel: #{name.humanize.to_json}, name: #{name.to_json}, value: #{item.send(name).to_json}, allowBlank: false}" 
 end
   
 def extjs_std_hiddenfield(name, item) 
  ret = "{xtype: 'hiddenfield', name: #{name.to_json}, value: #{item.send(name).to_json}}" 
 end
 
 def extjs_std_booleanfield(name, item, p = {}, attr = {}) 
  add_attr = extsj_create_attr_str(attr)
  ret = "{xtype: 'checkbox', name: #{name.to_json}, value: #{item.send(name).to_json}, fieldLabel: #{(p[:fieldLabel] || name.humanize).to_json}, 
   inputValue: true,
   uncheckedValue: false  #{add_attr} }" 
 end

 def extjs_std_textareafield(name, item)
  ret = "{xtype: 'textareafield', name: #{name.to_json}, value: #{item.send(name).to_json}, fieldLabel: #{name.humanize.to_json}, anchor: '100%', grow: true}"
 end

 def extjs_std_datetimefield(name, item) 
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
  ret += " {xtype: 'datefield', name: #{name_date.to_json}, value: #{item.send(name).to_date.to_json}, allowBlank: false}"
  ret += ",{xtype: 'timefield', name: #{name_time.to_json}, value: #{item.send(name).to_s(:time).to_json}, allowBlank: false}"  
  ret += "]}" 
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
         layout: 'hbox',
         anchor: '100%',
         defaults: {xtype: 'textfield', flex: 1, hideLabel: #{(p[:hideLabel] || false).to_json}},
         items: [
          " + items.join(', ') + "
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
