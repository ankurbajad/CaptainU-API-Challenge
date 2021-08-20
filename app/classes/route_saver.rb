class RouteSaver

  def initialize(vehicle, supply_chain_id, route_params, route=nil)
    @supply_chain_id = supply_chain_id
    @vehicle = vehicle
    @route_params = route_params
    @route_schedule_params = route_params[:route_schedules_attributes]
    @route = route
    @errors = {}
  end

  def create
    begin
      set_route_time_zone
      build_route_schedule
      set_schedule_seq
      route = @vehicle.routes.new(route_params)
      route.save!
      route
    rescue => exception
      errors[:base] = exception.to_s
      false
    end
  end

  def update
    ActiveRecord::Base.transaction do
      clean_route_schedules
      build_route_schedule
      set_schedule_seq
      return route.update_attributes(route_params), route
    rescue => exception
      errors[:base] = exception.to_s
    end
  end


  attr_reader :route, :route_params,:route_schedule_params,:supply_chain, :errors

  private


  def build_route_schedule
    count = 1
    route_schedule_params.each do |route_schedule|
      start_time = Time.parse(route_schedule[:start_time].to_s)
      total_duration_days = calculate_days(total_duration_hours + calculate_hours(total_duration_minutes))
      Rails.logger.info "Total Duration Days: #{total_duration_days} "

      if total_duration_days < 1
        end_time = start_time + total_duration_hours.hours + total_duration_minutes.minutes
        Rails.logger.info "End Time: #{end_time.to_date} UTC End Time: #{end_time.utc.to_date} "
        calculate_schedule(route_schedule, start_time, end_time)
      else
        count = 0
        total_duration_days.to_i.times do
          count+=1
          end_time = get_end_of_day(start_time)
          route_schedule[:start_time] = start_time.utc
          route_schedule[:end_time] = get_end_of_day(start_time).utc
          route_schedule[:split] = true
          if (total_duration_days - count.days) > 1
            route_schedule_params << create_overlap_day(route_schedule, start_time, get_end_of_day(start_time).utc, count)
          else
            start_time += get_hours_remaining(24)
            route_schedule_params << create_overlap_day(route_schedule, start_time, end_time, count)
          end
        end
      end
      count += 1
    end
  end

  def calculate_schedule(route_schedule, start_time, end_time)
    if end_time.to_date < end_time.utc.to_date
      route_schedule_params << create_overlap_day(route_schedule, start_time.utc, route_schedule[:end_time].to_utc, count )
      route_schedule[:start_time] = start_time.utc
      route_schedule[:end_time] = get_end_of_day(start_time).utc
      route_schedule[:split] = true
    else
      route_schedule[:start_time] = start_time.utc
      route_schedule[:end_time] = end_time.utc
      route_schedule[:split] = false
    end
  end

  def create_overlap_day(route_schedule, start_time, end_time, count)
    {
      day_of_week: route_schedule[:day_of_week].eql?(6) ? 0 : route_schedule[:day_of_week] + 1 ,
      week_number: route_schedule[:day_of_week].eql?(6) ? route_schedule[:week_number] + 1 : route_schedule[:week_number],
      start_time: get_end_of_day(start_time),
      end_time: end_time.utc,
      closed: false,
      split: true,
      order: count + 1,
      route_schedules_attributes: route_schedule_params[:route_stops_attributes]
    }
  end

  def clean_route_schedules
    RouteSchedule.where(route.id).destroy_all
  end

  def calculate_days(duration)
    duration/24
  end

  def get_hours_remaining(duration)
    (duration - get_time_difference_end_of_day_hours(start_time)).hours
  end

  def get_end_of_day(time)
    Time.new(time.year, time.month, time.day, 24, 0, 0, 0)
  end

  def get_time_difference_end_of_day_hours(start_time)
    (start_time - end_of_day).hours
  end

  def total_duration_hours
    @hour_duration ||= route_params[:total_duration].split(':',2)[0].to_f
  end

  def total_duration_minutes
    @total_duration_minutes ||= route_params[:total_duration].split(':',2)[1].to_f
  end

  def calculate_hours(minutes)
    minutes/60
  end

  def set_schedule_seq
    count = 0
    route_schedule_sorted_params.each  do |route_schedule|
      route_schedule[:schedule_seq] = count
      count +=1
      set_route_stop_sequence(route_schedule)
    end
  end

  def set_route_stop_sequence(route_schedule)
    count = 1
    route_schedule[:route_stops_attributes].each do |route_stop|
      route_stop[:sequence] = count
      count +=1
    end

  end

  def set_route_time_zone
    route_params[:time_zone] = get_time_zone(@vehicle.facility_id)
  end

  def route_schedule_sorted_params
    route_schedule_params.sort_by { |route_schedule| [route_schedule[:week_number], route_schedule[:day_of_week], route_schedule[:start_time]] }.map
  end

  def get_time_zone(facility_id)
    @time_zone ||= Facility.find(facility_id).time_zone
  end

end
