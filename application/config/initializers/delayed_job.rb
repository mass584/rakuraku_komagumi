Delayed::Worker.max_run_time = 96.hours
Delayed::Worker.read_ahead = 4
Delayed::Worker.delay_jobs = !Rails.env.test?
Delayed::Worker.logger = Logger.new(Rails.root.join('log', 'delayed_job.log'))
