class SendReportToInspect
  
  def call
    items = HandlingHeader.where('1=1').not_closed.locked_INSPECT.joins(:shipowner).where("manage_empty = true or manage_full = true")
    text_email = "<table>"
    
    items.group_by { |r| r.shipowner_id}.each do |so_id, to_inspects|
      so = Shipowner.find(so_id)       
      text_email += "<tr><td>Compagnia <b>#{so.name}&nbsp;</b></td><td>numero container da ispezionare: <b>#{to_inspects.count}</b></td></tr>"      
    end #items
    
    text_email += "</table>"
    LogEvent.send_mail_html(Shipowner.first, 'MAIL_REP', 
         TabConfig.get_notes('EMAIL', 'MAIL_RIEP', 'INSPECT').to_s, 
        'Riepilgo container da ispezionare', text_email)
  
    
  end #call
  
end