class VacationCompletionJob < ApplicationJob
  queue_as :default

  def perform
    completed_count = 0
    
    UserVacation.where(status: ['active', 'paused'])
                .where('end_date < ?', Date.current)
                .find_each do |vacation|
      
      vacation.update!(status: 'completed')
      completed_count += 1
      
      Rails.logger.info "Completed vacation #{vacation.id} for customer #{vacation.customer_id}"
    end

    Rails.logger.info "Vacation completion job completed. #{completed_count} vacations marked as completed."
    completed_count
  end
end