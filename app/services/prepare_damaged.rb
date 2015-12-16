class PrepareDamaged
  def call
    #recupero tutti gli hi di cui ancora devo inviare la email (se necessario)
    HandlingHeader.where('handling_status=?', 'OPEN').where('lock_type IN(\'DAMAGED\', \'DAMAGED_AU\')').limit(3000).each do |hh|
            
      #item con lock_type = 'DAMAGED'
      hi_damaged = hh.last_dett_by_lock_type('DAMAGED')
      
      #verifico che non esista gia' il record in repair
      rpi = RepairHandlingItem.find_by_handling_item_id(hi_damaged.id)      
      next if !rpi.nil?      
      
      print "\n----------------------------\n"
      print "id: #{hh.id}, container_number: #{hh.container_number}"      

      n = RepairHandlingItem.new      
      
      n.handling_item_id = hi_damaged.id
      n.repair_status = 'OPEN'
      n.in_garage_at = hi_damaged.datetime_op
      n.in_garage_user_id = hi_damaged.created_user_id
      
      #note
      if !hi_damaged.notes.to_s.empty? || !hi_damaged.notes_int.to_s.empty?
        n.in_garage_notes = ""
        n.in_garage_notes += "* " + hi_damaged.notes unless hi_damaged.notes.to_s.empty?
        n.in_garage_notes += "* " + hi_damaged.notes_int unless hi_damaged.notes_int.to_s.empty?
      end


      if hh.lock_type == 'DAMAGED_AU'
        hi_damaged_au = hh.last_dett_by_lock_type('DAMAGED_AU')
        
        n.estimate_at = n.estimate_sent_at = n.estimate_authorized_at = hi_damaged_au.datetime_op
        n.estimate_user_id = n.estimate_sent_user_id = n.estimate_authorized_user_id = hi_damaged_au.created_user_id
        
        #note
        if !hi_damaged_au.notes.to_s.empty? || !hi_damaged_au.notes_int.to_s.empty?
          n.estimate_authorized_notes = ""
          n.estimate_authorized_notes += "* " + hi_damaged_au.notes unless hi_damaged_au.notes.to_s.empty?
          n.estimate_authorized_notes += "* " + hi_damaged_au.notes_int unless hi_damaged_au.notes_int.to_s.empty?
        end

      end
      
      n.save!
    end
  end #call
end #class
