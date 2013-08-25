class Manual < Project
  # Manual Time tracking class, if no external one is used.
  module Base

    def duration() 0 end
    def earned_on( date ) 0.to_f end
    def method_missing( method_name ) nil end
    def finish() start end
    def initialized?() true end

  end
end