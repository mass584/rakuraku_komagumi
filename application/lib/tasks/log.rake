namespace :log do
  task rotate: :environment do
    log_files = Dir.entries(Rails.root.join('log')).reject do |item|
      (item =~ /#{Rails.env}\.log\./).nil?
    end
    log_files.each do |filename|
      filepath = Rails.root.join("log/#{filename}")
      hostname = `hostname`.strip
      command = "aws s3 mv #{filepath} s3://bucket_name/log/rails/#{filename}.#{hostname}"
      system(command)
    end
  end
end
