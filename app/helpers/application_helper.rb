module ApplicationHelper

 def extjs_std_combo(name, item, p = {})
 
  if p[:displayField].nil?
    p[:valueField] = 'cod'
    p[:displayField] = 'descr'
  else
    p[:valueField] = p[:valueField] || p[:displayField]
  end
  
  ret = "
    {
      xtype: 'combobox', name: #{name.to_json}, value: #{p[:value].to_json}, 
      fieldLabel: #{name.humanize.to_json},
      displayField: #{p[:displayField].to_json},
      valueField: #{p[:valueField].to_json || p[:displayField].to_json},
      forceSelection: true,
      allowBlank: false,
      triggerAction: 'all',  
      store: #{p[:store]},
      listeners: {#{p[:listeners]}}
    }
    "
  return ret 
 end


 def extjs_std_combo_model(name, item, p = {})
  field_name = name + '_id'
  model_class = name.camelize.constantize

  ret = "
    {
      xtype: 'combobox', name: #{field_name.to_json}, value: #{item.send(field_name).to_json}, 
      fieldLabel: #{name.humanize.to_json},
      displayField: #{model_class.combo_displayField.to_json},
      valueField: 'id',
      forceSelection: true,
      allowBlank: false,
      triggerAction: 'all',  
      store: #{p[:store] || extjs_std_store_model(name)},
      listeners: {#{p[:listeners]}}
    }
    "
  return ret 
 end
 
 
 def extjs_std_textfield(name, item)
  ret = "{xtype: 'textfield', fieldLabel: #{name.humanize.to_json}, name: #{name.to_json}, value: #{item.send(name).to_json}, maxLength: #{item.class.columns_hash[name].limit}, allowBlank: false}" 
 end
 
 def extjs_std_datefield(name, item) 
  ret = "{xtype: 'datefield', fieldLabel: #{name.humanize.to_json}, name: #{name.to_json}, value: #{item.send(name).to_json}, allowBlank: false}" 
 end
 
 def extjs_std_hiddenfield(name, item) 
  ret = "{xtype: 'hiddenfield', name: #{name.to_json}, value: #{item.send(name).to_json}}" 
 end



 def extjs_std_store_model(model)
  ret = "Ext.create('Ext.data.Store', {
          model: #{model.camelize.to_json},
          autoLoad: true,
          proxy: {
              type: 'ajax',
              url: '/#{model.pluralize}/get_combo_data',              
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
     
      
end
