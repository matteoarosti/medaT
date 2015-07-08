class VerifyImports
  def call
    #recupero tutti gli hi di cui ancora devo inviare la email (se necessario)
    ImportHeader.where('import_status=?', 'OPEN').limit(100).each do |ih|
      print "\n----------------------------\n"
      print "\nNave: #{ih.ship.name} - Viaggio: #{ih.voyage.to_s}"

      c_close = c_open = 0

      #verifico se tutti gli ii sono chiusi
      ih.import_items.each do |ii|
       ii.status.nil? ? c_open+=1 : c_close+=1
      end

      print "\nChiusi: #{c_close.to_s}"
      print "\nAperti: #{c_open.to_s}"

      if c_open == 0 && c_close > 0
       print "\n ***** CHIUDO ****** \n"
       #chiudo l'import
       ih.import_status = 'CLOSE'
       ih.save!
      end

      print "\n\n"

    end
  end #call
end #class
