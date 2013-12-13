class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  has_many :projects
  serialize :settings, Hashery::OpenCascade
  
  def refresh_data
    Project.implementations.each do |modul|
      module_settings = "settings.#{modul.to_s.downcase}"
      api_key = eval( "#{module_settings}.api_key" )
      com = modul::Communicator.new( api_key )
      entries_str = "#{module_settings}.time_entries"
      eval "#{entries_str} = #{com.time_entries}"
      eval "#{module_settings}.last_pull_request = Time.now"
      save!
    end
    
    projects.each do |project|
      project.refresh_data if project.needs_refresh?
    end
  end
end
