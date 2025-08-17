# Vacation feature configuration
module VacationConfig
  CUTOFF_TIME = ENV.fetch('VACATION_CUTOFF_TIME', '17:00').freeze
  MAX_VACATION_DURATION = ENV.fetch('MAX_VACATION_DURATION_DAYS', '90').to_i.days
  DEFAULT_TIMEZONE = ENV.fetch('DEFAULT_TIMEZONE', 'UTC').freeze

  def self.cutoff_time_for_timezone(timezone)
    Time.parse(CUTOFF_TIME).in_time_zone(timezone || DEFAULT_TIMEZONE)
  end

  def self.is_after_cutoff?(timezone = nil)
    current_time = Time.current.in_time_zone(timezone || DEFAULT_TIMEZONE)
    cutoff = cutoff_time_for_timezone(timezone)
    
    current_time.hour >= cutoff.hour && current_time.min >= cutoff.min
  end

  def self.effective_start_date(requested_start_date, timezone = nil)
    return requested_start_date if requested_start_date > Date.current

    if is_after_cutoff?(timezone)
      [requested_start_date, Date.current + 1.day].max
    else
      [requested_start_date, Date.current].max
    end
  end
end