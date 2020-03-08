module AwsFunction
  module Batch
    module_function
  
    def submit_optimization_job(job_name, schedulemaster_id)
      Rails.logger.info(
        "Submit batch job to AWS Batch. job_name: #{job_name}. schedulemaster_id: #{schedulemaster_id}"
      )
      client = Aws::Batch::Client.new(
        region: ENV['AWS_BATCH_REGION'],
        access_key_id: ENV['AWS_ACCESS_KEY_ID'],
        secret_access_key: ENV['AWS_SECRET_ACCESS_KEY']
      )
      client.submit_job(
        job_name: job_name,
        job_definition: ENV['AWS_BATCH_JOB_DEFINITION'],
        job_queue: ENV['AWS_BATCH_JOB_QUEUE'],
        container_overrides: {
          environment: [
            { name: 'OPT_JOB_NAME', value: job_name },
            { name: 'OPT_SCHEDULEMASTER_ID', value: schedulemaster_id },
            { name: 'OPT_DATABASE_HOST', value: ENV['DATABASE_HOSTNAME'] },
            { name: 'OPT_DATABASE_NAME', value: ENV['DATABASE_NAME'] },
            { name: 'OPT_DATABASE_USERNAME', value: ENV['DATABASE_USERNAME'] },
            { name: 'OPT_DATABASE_PASSWORD', value: ENV['DATABASE_PASSWORD'] }
          ]
        }
      )
    end
  end
end
  