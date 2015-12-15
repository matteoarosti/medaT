class RepairImportsController < ApplicationController
  
  # Form per upload e caricamento file
  def import_file
  end
  
  
  def exe_import_file
    file = params[:file]
    ss = Roo::Excelx.new(file.path, nil, :ignore)

    ss.default_sheet = 'processi_listini'

    (3..ss.last_row).each do |i|
     logger.info "riga #{i} (excel id: #{ss.row(i)[0]})"
     continue if ss.row(i).to_s.empty?
     position_id  = ss.row(i)[1].to_i
     component_id = ss.row(i)[3].to_i

     n_rp = RepairProcessing.find_by_id(ss.row(i)[0].to_i)

     if n_rp.nil?
      logger.info "Creo nuovo processing"
      n_rp = RepairProcessing.new
       n_rp.repair_position_id    = position_id
       n_rp.repair_component_id   = component_id
       n_rp.description_it        = ss.row(i)[7]
       n_rp.description_en        = ss.row(i)[8]
       n_rp.preparation_time_type = ss.row(i)[9]
      n_rp.save!
      exit if n_rp.id != ss.row(i)[0].to_i
     end

      #CMA
      shipowner_id = 3
      if !ss.row(i)[10].to_s.empty?
       n_p = RepairPrice.find_or_create_by(repair_processing_id: ss.row(i)[0].to_i, shipowner_id: shipowner_id)
       n_p.customer_time            = ss.row(i)[10]
       n_p.customer_material_price  = ss.row(i)[11]
       n_p.provider_time            = ss.row(i)[12]
       n_p.provider_material_price  = ss.row(i)[13]
       n_p.code1                    = ss.row(i)[14].to_s
       n_p.code2                    = ss.row(i)[15].to_s
       n_p.save!
      end
     

      #MAERSK LINE
      shipowner_id = 2
      if !ss.row(i)[16].to_s.empty?
       n_p = RepairPrice.find_or_create_by(repair_processing_id: ss.row(i)[0].to_i, shipowner_id: shipowner_id)
       n_p.customer_time            = ss.row(i)[16]
       n_p.customer_material_price  = ss.row(i)[17]
       n_p.provider_time            = ss.row(i)[18]
       n_p.provider_material_price  = ss.row(i)[19]
       n_p.code1                    = ss.row(i)[20].to_s
       n_p.code2                    = ss.row(i)[21].to_s
       n_p.save!
      end
     
    end
               
    render json: {:success => true}
  end
  
end
