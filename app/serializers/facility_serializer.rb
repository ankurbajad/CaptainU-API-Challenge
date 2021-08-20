class FacilitySerializer

  attr_reader :facility

  def initialize(facility)
    @facility = facility
  end

  def serialized_hash
    {
      id: facility.id,
      facility_type_id: facility.facility_type_id,
      supply_chain_id: facility.supply_chain_id,
      name: facility.name,
      address: facility.address,
      time_zone: facility.time_zone,
      longitude: facility.longitude,
      altitude: facility.altitude,
      total_area: facility.total_area,
      storage_capacity: facility.storage_capacity,
      carbon_output: (facility.carbon_output * 60).round(2),
      operation_cost: (facility.operation_cost * 60).round(2),
      rent_cost: (facility.rent_cost * 60).round(2),
      energy_cost: (facility.energy_cost * 60).round(2),
      labor_cost: (facility.labor_cost * 60).round(2),
      time_zone: facility.time_zone
    }
  end
end
