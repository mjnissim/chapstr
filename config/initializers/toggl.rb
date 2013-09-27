class Toggl < Project
  API_URL = "https://www.toggl.com/api/v8"

  DYNAMIC_FINISH_LINE = /(\d+) of (\d+)/i
  NUMBER_APPEARS = /.*\W(\d+)/
  
  # https://www.toggl.com/user/edit
  
  def self.time_entries api_key, from_date: 15.years.ago
    tomorrow = CGI.escape( Date.tomorrow.to_time.iso8601 )
    from_date = CGI.escape( from_date.to_time.iso8601 )
    url = "#{API_URL}/time_entries"
    url << "?start_date=#{from_date}&end_date=#{tomorrow}"
    get( url, api_key )
  end
  
  def self.get_workspace_id api_key
    url = "#{API_URL}/workspaces"
    ar = get( url, api_key )
    ar.first.values.first
  end
  
  def self.projects api_key
    ws_id = get_workspace_id( api_key )
    url = "#{API_URL}/workspaces/#{ws_id}/projects"
    @@projects = get( url, api_key )
  end
  
  # Returns a hash of module project IDs and names.
  # Good for select-lists, etc.
  def self.projects_list api_key
    # FIX: fill projects list with inject instead of 4 lines.
    hash = {}
    projects( api_key ).each do |project|
      hash[ project['id'] ] = project['name']
    end
    hash
  end
  
  
  # Returns an array of hashes for a given url.
  def self.get url, api_key
    uri = URI.parse( url )
    http = Net::HTTP.new( uri.host, uri.port )
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Get.new( uri.request_uri )
    request.basic_auth( api_key, "api_token" )
    request["Content-Type"] = "application/json"
    response = http.request( request )
    
    if response.code.to_i==200 # OK
      hash = JSON.parse( response.body )
    elsif response.code.to_i==403 # Authentication
      raise Exceptions::AuthenticationError
    else
      puts "Error, code #{ response.code }."
      puts response.body
    end
  end
  
  
  module Base
    
    def self.extended klass
      klass.user.settings.toggl ||= OpenStruct.new
      klass.settings['toggl'] ||= OpenStruct.new
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
    
    def initialized?
      project_hash.present?
    end
    
    # Scans entry descriptions for dynamic finish line.
    # Returns a dynamic finish line, or db-field value, or 
    # the same value as start.
    # Dynamic finish line means a document might have started
    # as "Page 5 of 30" but becomes "Page 10 of 32" and so on,
    # which is a common situation when editing documents.
    def finish
      found = entries.reverse.find do |en|
        en['description'] and en['description'].match( DYNAMIC_FINISH_LINE )
      end
      return $2.to_i if found
      # FIX: Should 'finish' ever return a db-field in the Toggl module?
      read_attribute( :finish ) || start
    end

    # Time entries for this project or stage.
    def entries
      ( entries = settings['toggl'].entries ) and return entries

      if is_stage?
        entries = master.entries_for( tag: title )
      else
        # What if there aren't any entries initialized in the user settings?
        entries = user.settings.toggl.entries.select do |en|
          en['pid'] == project_hash['id']
        end
      end
      settings['toggl'].entries = entries
      save!
      entries
    end
    
    # def entries
    #   return @entries if @entries
    # 
    #   if is_stage?
    #     @entries = modul.entries_for(
    #       tag: title,
    #       entries_to_search: master.entries
    #     )
    #   else
    #     if settings['entries'].present?
    #       # When delayed_job works with rails 4.0...
    #       # self.delay.refresh_data
    #       # until then:
    #       refresh_data
    #     else
    #       refresh_data
    #     end
    #     @entries = settings['entries']
    #   end
    # end
    
    def refresh_data
      # reject entries without projects or whose project is not the one I need
      settings['entries'] = modul.time_entries( api_key ).select do |en|
        en['pid'] == project_hash['id']
      end
      save!
    end
    
    def api_key
      user.settings.toggl.api_key
    end
    
    
    # Time entries for a specific tag or date.
    # Optionally supply entries to search from.
    def entries_for tag: nil, date: nil, before_date: nil,
      from_date: nil

      entries.select do |en|
        ( tag and en['tags'].map{ |t| t.upcase }.include?( tag.upcase ) ) ||
        ( date and en['start'].to_date == date ) ||
        ( before_date and en['start'].to_date < before_date ) ||
        ( from_date and en['start'].to_date >= from_date )
      end
    end

    
    # Project duration in seconds.
    def duration
      entries.map{ |en| en['duration'] }.sum
    end
    
    def date_started
      entries.first['start'].to_date if entries.any?
    end

    def date_ended
      entries.last['stop'].to_date if entries.any?
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
      
      if date_before_last.nil?
        prev_milestone = start
      else
        prev_milestone = milestone( entries: entries_before )
      end
      
      latest_milestone = milestone( entries: entries_for_date )
      
      if latest_milestone and prev_milestone
        latest_milestone - prev_milestone
      end
    end
    
    def earned_on date
      from_stages = stages.map{ |stage| stage.earned_on( date ) }.sum
      sum = milestones_for( date ).to_i * per_milestone.to_f
      from_stages + sum
    end
    
    def last_earned
      earned_on last_date
    end
    
    def current_stage
      dates = super_master.stages.map do |stg|
        date = stg.entries.last['start'].to_datetime if stg.entries.any?
        [ stg, date ]
      end
      
      dates.sort_by{ |d| d[1] }.last[0] unless dates.none?
    end
    
    def current_stage?
      self == current_stage
    end

    def project_hash
      return @project_hash if @project_hash
      
      if super_master?
        @project_hash = modul.projects( api_key ).find do |pr|
          pr['id'] == tt_project_id
        end
      end
      
      @project_hash
    end
  end
end