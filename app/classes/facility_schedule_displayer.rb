class FacilityScheduleDisplayer
  attr_reader :facility_schedules, :time_zone

  def self.convert(facility_schedules)
    new(facility_schedules).convert
  end

  def initialize(facility_schedules)
    @facility_schedules = facility_schedules
    @errors = {}
  end

  def convert
    split_index = nil
    new_facility_schedules = Array.new
    facility_schedules.each_with_index  do  |facility_schedule, i |
     next if i == split_index
     if  facility_schedule.split
        split_index = i + 1
        associated_facility_schedule = facility_schedules[split_index]
        if associated_facility_schedule.present?
          facility_schedule.start_time = facility_schedule.start_time
          facility_schedule.end_time = associated_facility_schedule.end_time
          new_facility_schedules << facility_schedule
        end
     else
       new_facility_schedules << facility_schedule
     end
    end
    new_facility_schedules
  end

end
