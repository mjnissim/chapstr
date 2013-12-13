desc "Refresh Data"
task :refresh_data => :environment do
end

desc "Program upgrade (single use task)"
task :program_upgrade => :environment do
  User.connection.execute "UPDATE users set settings=NULL"
  Project.connection.execute "UPDATE projects set settings=NULL"
  Project.masters.each do |pr|
    user = pr.user
    user.settings.toggl.api_key = ENV['TOGGL_API_KEY']
    user.save!
  end
end
