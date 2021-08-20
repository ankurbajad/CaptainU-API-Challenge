class ExportService < ApplicationService

  def initialize(params, user)
    if params[:id].present?
      @ids = params[:id].split(',')
    else
      @ids = user.supply_chains.collect(&:id)
    end
  end

  def call
    temp = {}
    path = []
    @supply_chains = SupplyChain.where(id: @ids)
    supply_chain_data = @supply_chains.to_csv
    path << supply_chain_data

    # Get Product Data
    @products = Product.where(supply_chain_id: @ids)
    product_data = @products.to_csv
    path << product_data

    # get facility and facility_items data
    @facilities = Facility.where(supply_chain_id: @ids)
    facility_data = @facilities.to_csv
    path << facility_data

    # get vehicle data
    @vehicles = Vehicle.where(facility_id: @facilities.collect(&:id))
    vehicle_data = @vehicles.to_csv
    path << vehicle_data

    return path
  end
end
