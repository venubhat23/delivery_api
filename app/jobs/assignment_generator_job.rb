class AssignmentGeneratorJob < ApplicationJob
  queue_as :default

  def perform(start_date: Date.current, end_date: 28.days.from_now.to_date)
    total_generated = AssignmentGeneratorService.generate_for_all_schedules(
      start_date: start_date,
      end_date: end_date
    )

    Rails.logger.info "Assignment generation job completed. Generated #{total_generated} assignments for date range #{start_date} to #{end_date}"
    total_generated
  end
end