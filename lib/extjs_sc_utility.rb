  #PER EXTJS SCAFFOLD
 
 
 class ActiveRecord::Base

  ###################################################################
  # EXTJS SCAFFOLD
  ###################################################################
  def self.extjs_sc_columns
    ret = []
    columns.map {|c| ret << extjs_sc_crt_column(c)}
    ret
  end
  
  def self.extjs_sc_form_fields
    ret = []
    columns.map {|c| ret << extjs_sc_crt_field(c)}
    ret
  end     


end

 
 
 
 ####################################### 
 #definizione colonna per GRID
 #######################################
 def extjs_sc_crt_column(c)
  ret = {}
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
  ret[:fieldLabel] = c.name
  ret[:bind] = "{rec.#{c.name}}"  
  
  ret[:disabled] = true if c.name == 'id'
  
  case c.type
   when :string
    ret[:maxLength] = c.limit
  end  
  
  return ret
 end
  
  
