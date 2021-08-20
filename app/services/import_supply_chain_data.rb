require 'csv'
class ImportSupplyChainData
  def self.call(file_ids, user_id)
    @user = user_id
    supply_chain_spreadsheet = open_spreadsheet(file_id(file_ids, 'supplychain'))
    header = supply_chain_spreadsheet.row(1)

    product_spreadsheet = open_spreadsheet(file_id(file_ids, 'product'))
    product_header = product_spreadsheet.row(1)

    facility_spreadsheet = open_spreadsheet(file_id(file_ids, 'facility'))
    facility_header = facility_spreadsheet.row(1)

    vehicle_spreadsheet = open_spreadsheet(file_id(file_ids, 'vehicle'))
    vehicle_header = vehicle_spreadsheet.row(1)

    product_count = 2
    facility_count = 2
    vehicle_count = 2
    @manage_ids = []
    begin
      ActiveRecord::Base.transaction do
        # supply_chain_create
        (2..supply_chain_spreadsheet.last_row).each do |i|
          row = row(header, supply_chain_spreadsheet.row(i))
          if row['SupplyChain:id'].present?
            @supply_chain = SupplyChain.new(supply_chain_params(row(header, supply_chain_spreadsheet.row(i)), 'supply_chain'))
            @supply_chain.user_id = user_id
            if @supply_chain.save
            else
              @supply_chain.name = rename(@supply_chain.name)
              @supply_chain.save
            end
            @ids['new_supply_chain_id'] = @supply_chain.id
            @manage_ids << @ids
          end
        end
        # product create
        (product_count..product_spreadsheet.last_row).each do |i|
          @product_row = (product_params(row(product_header, product_spreadsheet.row(i)), 'product'))
          if valid?
            @product = @supply_chain.products.new(@product_row)
            @product.save
            @ids['new_product_id'] = @product.id
            @manage_ids << @ids
            product_count += 1
          end
          break unless valid?
        end
        #facility create
        (facility_count..facility_spreadsheet.last_row).each do |i|
          @facility_row = row(facility_header, facility_spreadsheet.row(i))
          if valid_facility?
            if @facility_row['Facility:id'].present?
              facility_params = (facility_params(row(facility_header, facility_spreadsheet.row(i)), 'facility'))
              @facility = Facility.new(facility_params)
              @facility.save!
              @ids['new_facility_id'] = @facility.id
              @manage_ids << @ids
            end
          end
          break unless valid_facility?
        end
        # vehicle create
        (vehicle_count..vehicle_spreadsheet.last_row).each do |i|
          @vehicle = row(vehicle_header, vehicle_spreadsheet.row(i))
          if valid_vehicle?
            @vehicle = Vehicle.new(vehicle_params(row(vehicle_header, vehicle_spreadsheet.row(i)), 'vehicle'))
            @vehicle.facility_id = vehicle_params(row(vehicle_header, vehicle_spreadsheet.row(i)), 'vehicle')['facility_id']
            @vehicle.save
            vehicle_count += 1
          end
          break unless valid_vehicle?
        end
      end
    rescue Exception => e
      return false, e.message
    end
    return true, user_id, 'Upload has been done, Please reload page!'
  end

  def self.supply_chain_params(row, modelname)
    @ids = {}
    @ids[('csv_' + modelname + '_id')] = row['SupplyChain:id']
    get_data(row, 'SupplyChain').reject! { |k| k == 'id' }
  end

  def self.product_params(row, modelname)
    @ids = {}
    params = get_data(row, modelname.capitalize)
    @ids[('csv_' + modelname + '_id')] = params['id']
    return params.delete_if { |k, v| ['id', 'type'].include? k }
  end

  def self.facility_params(row, modelname)
    @ids = {}
    params = get_data(row, modelname.capitalize)
    @ids[('csv_' + modelname + '_id')] = params['id']
    supply_chain_id = params['supply_chain_id']
    new_supply_chain_id = @manage_ids.select { |p| p['csv_supply_chain_id'].eql?(supply_chain_id) }[0]['new_supply_chain_id']
    params['facility_type_id'] = FacilityType.find_by(name: params['type']).id
    params['supply_chain_id'] = new_supply_chain_id
    return params.delete_if { |k, v| ['id', 'type'].include? k }
  end

  def self.vehicle_params(row, modelname)
    params = get_data(row, modelname.capitalize)
    facility_id = params['facility_id']
    new_facility_id = @manage_ids.select { |p| p['csv_facility_id'].eql?(facility_id) }[0]['new_facility_id']
    params['vehicle_type_id'] = VehicleType.find_by(name: params['vehicle_type']).id
    params['facility_id'] = new_facility_id
    return params.delete_if { |k, v| ['id', 'vehicle_type'].include? k }
  end

  def self.get_data(row, modelname)
    new_row = {}
    data = row.select { |key, value| key.include?(modelname) }
    data.each do |key, value|
      new_row[key.split(':')[1]] = value
    end
    return new_row
  end

  def self.row(header, row)
    row = Hash[[header, row].transpose]
    return row
  end

  def self.valid?
    p_s_c_id = @product_row['supply_chain_id']
    supply_chain_id = @manage_ids.select { |s| s['csv_supply_chain_id'].eql?(p_s_c_id) }
    if supply_chain_id.present?
      return true
    else
      return false
    end
  end

  def self.valid_facility?
    old_product_id = @facility_row['Fac-item:product_id']
    new_product_id = @manage_ids.select { |s| s['csv_product_id'].eql?(old_product_id) }
    if new_product_id.present?
      return true
    else
      return false
    end
  end

  def self.valid_vehicle?
    old_facility_id = @vehicle['Vehicle:facility_id']
    new_facility_id = @manage_ids.select { |s| s['csv_facility_id'].eql?(old_facility_id) }
    if new_facility_id.present?
      return true
    else
      return false
    end
  end

  def self.file_id(file_ids, file_name)
    return file_ids.select { |f| f[:file_name].eql?(file_name) }.last[:id]
  end

  def self.open_spreadsheet(file)
    import_export_file = ImportExportFile.find(file)
    case File.extname(import_export_file.file.filename.to_s)
    when '.csv' then Roo::CSV.new(Rails.application.routes.url_helpers.url_for(import_export_file.file), csv_options: { encoding: 'iso-8859-1:utf-8' })
    else raise "Unknown file type: #{import_export_file}"
    end
  end

  def self.rename(s_name)
    count = 0
    old_name = s_name
    while SupplyChain.find_by_name(old_name).present? do
      count += 1
      new_name = old_name.gsub(/[(#{count - 1})]/, ' ')
      old_name = new_name + ' (' + count.to_s + ')'
    end
    return old_name
  end
end
