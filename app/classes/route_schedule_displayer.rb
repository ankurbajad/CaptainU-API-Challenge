class RouteScheduleDisplayer
  attr_reader :route_schedules, :time_zone

  def self.convert(route_schedules)
    new(route_schedules).convert
  end

  def initialize(route_schedules)
    @route_schedules = route_schedules
    @errors = {}
  end

  def convert
    split_index = nil
    new_route_schedules = Array.new
    route_schedules.each_with_index  do  |route_schedule, i |
     next if i == split_index
     if  route_schedule.split
        split_index = i + 1
        associated_facility_schedule = route_schedules[split_index]
        if associated_facility_schedule.present?
          route_schedule.start_time = route_schedule.start_time
          route_schedule.end_time = associated_facility_schedule.end_time
          new_route_schedules << route_schedule
        end
     else
       new_route_schedules << route_schedule
     end
    end
    new_route_schedules
  end

  def get_time_zone(facility_id)

  end

  def utc_offset_hours
    @utc_offset_hours ||= TimeZoneHelper.utc_offset_hours(time_zone)
  end
end
