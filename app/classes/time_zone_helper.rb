class TimeZoneHelper
  def self.utc_offset_seconds(time_zone)
    Time.use_zone(time_zone) do
      Time.zone.now
    end.utc_offset
  end

  def self.utc_offset_hours(time_zone)
    utc_offset_seconds(time_zone) / (60 * 60)
  end
end