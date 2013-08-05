class Toggl
  API_URL = "https://www.toggl.com/api/v6"
  API_KEY = ENV['TOGGL_API_KEY']

  DYNAMIC_FINISH_LINE = /(\d+) of (\d+)/i
  NUMBER_APPEARS = /.*\W(\d+)/
  
  def self.time_entries
    tomorrow = Date.tomorrow.to_formatted_s(:db)
    two_years_ago = 2.years.ago.to_date.to_formatted_s(:db)
    url = "#{API_URL}/time_entries.json"
    url << "?start_date=#{two_years_ago}&end_date=#{tomorrow}"
    get( url )
  end
  
  # Time entries for a specific tag or date.
  # Optionally supply entries to search from.
  def self.entries_for tag: nil, date: nil, before_date: nil,
    entries_to_search: time_entries
    
    entries_to_search.select do |en|
      ( tag and en['tag_names'].map{ |t| t.upcase }.include?( tag.upcase ) ) ||
      ( date and en['start'].to_date == date ) ||
      ( before_date and en['start'].to_date < before_date )
    end
  end
  
  # Returns an array of hashes for url.
  def self.get url
    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Get.new(uri.request_uri)
    request.basic_auth(API_KEY, "api_token")
    response = http.request(request)
    
    if response.code.to_i==200
      hash = JSON.parse(response.body)
      hash['data']
    else
      puts "Error, code #{response.code}."
      puts response.body
    end
  end
  
  class TTProject
    
    @@projects = nil
    
    def self.all
      return @@projects if @@projects
      
      url = "#{API_URL}/projects.json"
      @@projects = parent.get( url )
    end
    
    def self.list
      hash = {}
      all.each do |project|
        hash[ project['id'] ] = project['name']
      end
      hash
    end
    
    def initialize project
      @project = project
      
      if super_master?
        @project_hash = self.class.all.find do |pr|
          pr['id'] == @project.super_master.tt_project_id
        end
      end
    end

    # Take last number from description of latest time-entry.
    def milestone entries: entries
      entries.reverse.each do |en|
        desc = en['description']
        if desc.match( DYNAMIC_FINISH_LINE ) or
            desc.match( NUMBER_APPEARS )
          return $1.to_i
        end
      end
      nil
    end
    
    # Scans entry descriptions for dynamic finish line.
    # Returns a dynamic finish line, or nil if none.
    # Dynamic finish line means a document might have started
    # as "Page 5 of 30" but becomes "Page 10 of 32" and so on,
    # which is a common situation when editing documents.
    def finish
      $2.to_i if entries.reverse.find do |en|
        en['description'].match( DYNAMIC_FINISH_LINE )
      end
    end

    # Time entries for this project or stage.
    def entries
      return @entries if @entries

      if @project.is_stage?
        @entries = self.class.parent.entries_for(
          tag: @project.title,
          entries_to_search: @project.master.tt_project.entries
        )
      elsif local_store['entries'].present?
          # self.delay.refresh_data
          refresh_data
          @entries = local_store['entries']
      else
        refresh_data
        @entries = local_store['entries']
      end
    end
    
    def delayed_refresh
      @project.delay.refresh_data
    end
    
    def refresh_data
      # reject entries without projects or whose project is not the one I need
      local_store['entries'] = self.class.parent.time_entries.reject do |en|
        en['project'].nil? or not en['project']['id'].equal?( id )
      end
      @project.save!
    end
    
    def local_store
      @project.local_store
    end
    
    # Takes same arguments as the Toggl#entries_for class method,
    # but searches only this instance's project entries.
    def entries_for args
      args[:entries_to_search] = entries
      self.class.parent.entries_for( args )
    end
    
    # Project duration in seconds.
    def duration
      entries.map{ |en| en['duration'] }.sum
    end
    
    def entry_dates
      entries.map{ |en| en['start'].to_date }.uniq
    end
    
    def last_date
      entry_dates.last
    end
    
    def date_before_last
      date_before last_date
    end
    
    def date_before date
      entry_dates.reverse.find{ |d| d<date}
    end
    
    def milestones_for date
      entries_for_date = entries_for( date: date )
      entries_before = entries_for( before_date: date )
      
      prev_milestone = milestone( entries: entries_before ).to_i
      latest_milestone = milestone( entries: entries_for_date )
      
      latest_milestone - prev_milestone if latest_milestone
    end
    
    def earned_on date
      milestones_for( date ).to_i * @project.per_milestone.to_f
    end
    
    def last_earned
      earned_on last_date
    end

  private

    def project_hash
      @project_hash || @project.super_master.tt_project.project_hash
    end
    
    def super_master?
      @project == @project.super_master
    end
    
    def id
      project_hash['id']
    end
    
    
  end
end