class FacilitySaver
  def initialize(supply_chain, facility_params, facility=nil)
    @supply_chain = supply_chain
    @facility_params = facility_params
    @facility_schedule_params = facility_params[:facility_schedules_attributes]
    @facility = facility
    @errors = {}
  end

  def create
    begin
      convert_facility_to_min
      build_facility_schedule
      set_schedule_seq
      facility = supply_chain.facilities.new(facility_params)
      return facility.save, facility
    rescue => exception
      errors[:base] = exception.to_s
      return false, facility
    end
  end

  def update
    ActiveRecord::Base.transaction do
      convert_facility_to_min
      build_facility_schedule
      set_schedule_seq
      Rails.logger.info "Facility: #{facility.name}"
      return facility.update(facility_params), facility
    rescue => exception
      errors[:base] = exception.to_s
    end
  end

  private

  attr_reader :facility, :facility_params,:facility_schedule_params,:supply_chain, :errors

  def convert_facility_to_min
    facility_params[:carbon_output] = facility_params[:carbon_output].eql?(0) ? 0 : facility_params[:carbon_output].to_f/60
    facility_params[:operation_cost] = facility_params[:operation_cost].eql?(0) ? 0 : facility_params[:operation_cost].to_f/60
    facility_params[:rent_cost] = facility_params[:rent_cost].eql?(0) ? 0 : facility_params[:rent_cost].to_f/60
    facility_params[:energy_cost] = facility_params[:energy_cost].eql?(0) ? 0 : facility_params[:energy_cost].to_f/60
    facility_params[:labor_cost] = facility_params[:labor_cost].eql?(0) ? 0 : facility_params[:labor_cost].to_f/60
    facility_params
  end

  def add_facility_schedules(new_schedules)
    new_schedules.each{|schedule| facility_schedule_params << schedule}
  end

  def build_facility_schedule
    facility_schedule_params.each do |facility_schedule|
      start_time = Time.parse(facility_schedule[:start_time].to_s)
      end_time = Time.parse(facility_schedule[:end_time].to_s)

      if end_time.to_date < end_time.utc.to_date
        facility_schedule_params << create_overlap_day(facility_schedule, start_time, end_time)
        facility_schedule[:start_time] = start_time.utc
        facility_schedule[:end_time] = Time.new(start_time.year, start_time.month, start_time.day, 24, 0, 0, 0).utc
        facility_schedule[:split] = true
      else
        facility_schedule[:start_time] = Time.parse(facility_schedule[:start_time].to_s).utc
        facility_schedule[:end_time] = Time.parse(facility_schedule[:end_time].to_s).utc
      end
      convert_facility_schedule_product_minutes(facility_schedule[:facility_schedule_products_attributes])
      Rails.logger.info "Week Number: #{facility_schedule[:week_number]} and Day of Week: #{facility_schedule[:day_of_week]} Count:#{facility_schedule[:schedule_seq]}"
    end
  end

  def create_overlap_day(facility_schedule, start_time, end_time)
    start_time = start_time - 1.day
    {
      day_of_week: facility_schedule[:day_of_week].eql?(7) ? 1 : facility_schedule[:day_of_week] + 1 ,
      week_number: facility_schedule[:day_of_week].eql?(7) ? facility_schedule[:week_number] + 1 : facility_schedule[:week_number],
      start_time: Time.new(start_time.year, start_time.month, start_time.day, 24, 0, 0, 0),
      end_time: end_time.utc,
      closed: false,
      split: true,
      schedule_seq: 0,
      product_total_demand: facility_schedule[:product_total_demand],
      product_total_production: facility_schedule[:product_total_production],
      product_total_quantity: facility_schedule[:product_total_quantity],
      product_total_storage: facility_schedule[:product_total_storage],
      product_total_storage_per: facility_schedule[:product_total_storage_per],
      facility_schedule_products_attributes: facility_schedule[:facility_schedule_products_attributes]
    }
  end

  def convert_facility_schedule_product_minutes(facility_schedule_products)
    if facility_schedule_products.present?
      facility_schedule_products.each do |facility_schedule_product|
        facility_schedule_product[:demand] = facility_schedule_product[:demand].eql?(0) ? 0 : facility_schedule_product[:demand].to_f/60
        facility_schedule_product[:production] = facility_schedule_product[:production].eql?(0) ? 0 : facility_schedule_product[:production].to_f/60
      end
    end
  end

  def clean_facility_schedules
    FacilitySchedule.where(facility_id: facility.id).destroy_all
  end

  def set_schedule_seq
    count = 0
    facility_schedule_sorted_params.each  do |facility_schedule|
      facility_schedule[:schedule_seq] = count
      count +=1
    end
  end

  def set_facility_schedule_facility_id

  end

  def facility_schedule_sorted_params
    facility_schedule_params.sort_by { |facility_schedule| [facility_schedule[:week_number], facility_schedule[:day_of_week], facility_schedule[:start_time]] }.map
  end
end
