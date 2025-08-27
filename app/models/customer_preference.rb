class CustomerPreference < ApplicationRecord
  belongs_to :customer

  validates :language, inclusion: { in: %w[en es fr de it pt], message: "%{value} is not a valid language" }, allow_blank: true
  
  # Default values
  after_initialize :set_defaults, if: :new_record?

  # Helper methods to match the expected interface from Customer model
  def delivery_time_window
    return nil unless delivery_time_start && delivery_time_end
    "#{delivery_time_start.strftime('%H:%M')} - #{delivery_time_end.strftime('%H:%M')}"
  end

  def notification_settings
    # Parse the text field as JSON, fallback to empty hash
    return {} if notification_preferences.blank?
    
    begin
      JSON.parse(notification_preferences)
    rescue JSON::ParserError
      {}
    end
  end

  def notification_settings=(value)
    self.notification_preferences = value.is_a?(Hash) ? value.to_json : value.to_s
  end

  private

  def set_defaults
    self.language ||= 'en'
    self.notification_preferences ||= {}.to_json
    self.skip_weekends ||= false
  end
end