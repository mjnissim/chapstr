desc "Stop heroku workers"
task :stop_workers => :environment do
  puts "ATTEPTING TO STOP WORKERS..."
  system "RAILS_ENV=production bin/delayed_job stop"
end