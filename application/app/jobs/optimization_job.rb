class OptimizationJob < ApplicationJob
  queue_as :default

  def perform(job_name, schedulemaster_id)
    schedulemaster = Schedulemaster.find(schedulemaster_id)
    exepath = Rails.root.join('..', 'optimization', 'src', 'Main.py')
    command = "python #{exepath} #{schedulemaster_id}"
    begin
      system(command)
    rescue StandardError => e
      logger.warn(e)
      logger.warn('Calculation stopped by error.')
    end
  end
end
