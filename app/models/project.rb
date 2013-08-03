class Project < ActiveRecord::Base
  has_many :stages, :class_name => "Project",
    :foreign_key => :project_id
  belongs_to :master, :class_name => "Project", :foreign_key => :project_id
  has_many :invoices
  
  def self.masters
    where project_id: nil
  end
  
  # Recursively sums up all stages' relative progress.
  def relative_progress
    ar = stages.collect{ |pr| pr.relative_progress }
    
    if ar.any?
      ar.sum
    else
      ( relative_milestone.to_f / milestones ) * expected_percentage
    end
  end
  
  def entries
    tt_project.entries
  end
  
  def is_stage?
    master.present?
  end
  alias :stage? :is_stage?
  
  def super_master?
    self == super_master
  end
  
  # Recursively finds the super-master project.
  def super_master
    master ? master.super_master : self
  end
  
  # Which time tracking module you will use.
  # FIX: read_attribute might be empty string, and not nil,
  # so then this method might not work (method: tt_module).
  def tt_module
    read_attribute( :tt_module ) || master.tt_module
  end
  
  # Returns the equivalent time-tracking project object.
  def tt_project
    unless tt_module.nil?
      @tt_project ||= eval( "#{tt_module}::TTProject").new(self)
    end
  end
  
  # Recursively sums up all invoices from the project and its stages.
  def charged_so_far
    charges = stages.collect{ |pr| pr.charged_so_far }
    invoices.collect{ |inv| inv.total }.sum + charges.sum
  end
  alias :total_charges :charged_so_far
  
  def milestone
    tt_project.milestone
  end
  
  def milestones
    ( finish - start ) + 1
  end
  
  def relative_milestone
    return nil if not milestone
    ( milestone - start ) + 1
  end
  
  def start
    read_attribute( :start ) || 1
  end
  
  def finish
    ( tt_project.finish || read_attribute( :finish ) ) || 1
  end
  
  # TODO: expand 'remaining_milestones', make recursive.
  # It doesn't apply to master project.
  def remaining_milestones
    finish - milestone
  end
  
  # TODO: write 'remaining_hours' method.
  def remaining_hours
    
  end
  
  def next_charge
    ( pre_finalised_quote * relative_progress / 100 ) - charged_so_far
  end
  alias :outstanding_charge :next_charge
  
  def pre_finalised_quote
    quote - after_finalised
  end
  
  def duration
    tt_project.duration
  end
  
  def duration_in_hours
    duration / 60 / 60
  end
  
  def last_date
    tt_project.last_date
  end
    
  def per_hour_actual
    total_charge_so_far / duration_in_hours
  end
  
  def per_hour_expected
    quote / hours_expected
  end
  
  def per_milestone
    if stage?
      return 0 if milestones == 1 and not completed
      for_stage = pre_finalised_quote * expected_percentage / 100.0
      for_stage / milestones
    end
  end
  
  def earned_on date
    from_stages = stages.map{ |stage| stage.earned_on( date ) }.sum
    tt_project.earned_on( date ).to_f + from_stages
  end
  
  def total_charge_so_far
    charged_so_far + next_charge
  end
  alias :standing_charge total_charge_so_far
  
  def remaining_charge
    quote - super_master.charged_so_far
  end
  
  def quote
    read_attribute( :quote ) || super_master.quote
  end
  
  def after_finalised
    read_attribute( :after_finalised ) || super_master.after_finalised
  end
end
