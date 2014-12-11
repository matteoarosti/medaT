  #PER EXTJS SCAFFOLD
  
 
 
 class ActiveRecord::Base

  ###################################################################
  # EXTJS SCAFFOLD
  ###################################################################
  def self.extjs_sc_columns
    ret = []
    columns.map {|c|
      ret << extjs_sc_crt_column(c)
    }
    ret
  end
  
  def self.extjs_sc_form_fields
    ret = []
    columns.map {|c| ret << extjs_sc_crt_field(c)}
    ret
  end     


 #defaults
 def self.as_json_prop()
     return {}
 end

end #ActiveRecord::Base

 
 
 
 ####################################### 
 #definizione colonna per GRID
 #######################################
 def extjs_sc_crt_column(c)
  ret = {}
  
  if c.name[-3,3].to_s == '_id'
   ret[:text] = c.name
   ret[:dataIndex] = c.name + '_Name'
   ##ret[:renderer] = 'function(a, b, c){console.log(a); console.log(b);console.log(c)}'
   return ret
  end
  
  ret[:text] = c.name
  ret[:dataIndex] = c.name  
  case c.type
   when :datetime 
    ret[:xtype]  = 'datecolumn'
    ret[:format] = 'd/m/Y H:i:s'
    ret[:width]  = 140
   when :integer
    ret[:xtype]  = 'numbercolumn'
    ret[:align]  = 'right'
    ret[:format] = '0'
   else   
    ret[:flex]   = 1   
  end
  return ret
 end
 
 
 ####################################### 
 #definizione colonna PER FORM FIELD
 #######################################
 def extjs_sc_crt_field(c)
 
  ret = {} 
 
  if c.name[-3,3].to_s == '_id'
    ret[:xtype]       = 'combobox'
    ret[:fieldLabel]  = c.name
    ret[:multiselect] = false
    ret[:displayField] = 'title'
    ret[:valueField]  = 'codice'
    ret[:queryMode]   = 'local'
    ret[:bind] = {
      :value      => "{rec.#{c.name}}",
      #:selection => valore iniziale??
      :store      => '' 
    }
    
   return ret
  end 
 
 
  ret[:fieldLabel] = c.name
  ret[:bind] = "{rec.#{c.name}}"  
  
  ret[:disabled] = true if c.name == 'id'
  
  case c.type
   when :string
    ret[:maxLength] = c.limit
  end  
  
  return ret
 end
  
  
