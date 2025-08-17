class AssignmentGeneratorService
  attr_reader :schedule, :start_date, :end_date

  def initialize(schedule, start_date: Date.current, end_date: 28.days.from_now.to_date)
    @schedule = schedule
    @start_date = start_date
    @end_date = end_date
  end

  def generate
    return [] unless schedule&.status == 'active'

    generated_assignments = []
    
    (start_date..end_date).each do |date|
      next unless should_create_assignment_for_date?(date)
      next if customer_has_active_vacation_on?(date)
      next if assignment_already_exists?(date)

      assignment = create_assignment_for_date(date)
      generated_assignments << assignment if assignment.persisted?
    end

    generated_assignments
  end

  def self.generate_for_all_schedules(start_date: Date.current, end_date: 28.days.from_now.to_date)
    total_generated = 0
    
    DeliverySchedule.active.find_each do |schedule|
      service = new(schedule, start_date: start_date, end_date: end_date)
      generated = service.generate
      total_generated += generated.count
      
      Rails.logger.info "Generated #{generated.count} assignments for schedule #{schedule.id}"
    end

    Rails.logger.info "Total assignments generated: #{total_generated}"
    total_generated
  end

  private

  def should_create_assignment_for_date?(date)
    case schedule.frequency
    when 'daily'
      true
    when 'weekly'
      date.wday == schedule.start_date.wday
    when 'monthly'
      date.day == schedule.start_date.day
    when 'alternate_days'
      (date - schedule.start_date).to_i.even?
    else
      false
    end
  end

  def customer_has_active_vacation_on?(date)
    schedule.customer.has_active_vacation_on?(date)
  end

  def assignment_already_exists?(date)
    schedule.customer.delivery_assignments.exists?(
      scheduled_date: date,
      product: schedule.product
    )
  end

  def create_assignment_for_date(date)
    schedule.customer.delivery_assignments.create!(
      delivery_schedule: schedule,
      user: schedule.user,
      product: schedule.product,
      scheduled_date: date,
      quantity: schedule.default_quantity,
      unit: schedule.default_unit,
      status: 'scheduled',
      discount_amount: schedule.default_discount_amount || 0
    )
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error "Failed to create assignment for date #{date}: #{e.message}"
    OpenStruct.new(persisted?: false)
  end
end