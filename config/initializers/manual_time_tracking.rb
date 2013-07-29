class ManualTimeTracking
  class TTProject < Project
    attr_reader :finish
    
    def self.all
      # Implement this: @project.class.masters.where(module: 'ManualTimeTracking')
    end
    
    def self.list
      # return a hash.
    end
    
    def initialize project
      @project = project
    end

    def milestone
      read_attribute :milestone
    end
    
    # Project duration in seconds.
    def duration
      @project.hours_so_far.to_i * 60 * 60
    end

  end
end