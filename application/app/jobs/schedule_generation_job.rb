class ScheduleGenerationJob < ApplicationJob
  queue_as :default

  def perform(schedulemaster_id, queue_name, queue_type)
    schedulemaster = Schedulemaster.find(schedulemaster_id)
    exepath = Rails.root.join('lib', 'optimization', 'Main.py')
    logpath = Rails.root.join('log', 'optimization', "#{queue_name}.log")
    command = "python #{exepath} #{logpath} #{schedulemaster_id}"
    begin
      system(command)
      logger.info('Calculation successfully finished.')
    rescue StandardError => e
      logger.warn(e)
      logger.warn('Calculation stopped by error.')
    end
    schedulemaster.update!(
      calculation_status: 0,
      calculation_end: DateTime.now,
    )

    logpath = Rails.root.join('log', 'optimization', "#{queue_name}.log")
    command = "aws s3 mv #{logpath} s3://bucket_name/log/optimization/#{queue_name}.log.1"
    begin
      system(command)
      logger.info("Send #{queue_name}.log.1 to aws s3 bucket.")
    rescue StandardError => e
      logger.warn(e)
    end

    if queue_type == 'delayed_job'
      return
    end

    logpath = Rails.root.join('log', 'production.log')
    command = "aws s3 mv #{logpath} s3://bucket_name/log/optimization/#{queue_name}.log.2"
    begin
      system(command)
      logger.info("Send #{queue_name}.log.2 to aws s3 bucket.")
    rescue StandardError => e
      logger.warn(e)
    end
  end
end
