class Project < ActiveRecord::Base
  has_many :stages, class_name: "Project",
    foreign_key: :project_id, inverse_of: :master
  belongs_to :master, class_name: "Project", foreign_key: :project_id,
    inverse_of: :stages
  has_many :invoices
  belongs_to :user
  serialize :local_store, Hash

  NEW_PROJECT_TITLE = "New Project"
  
  @@implementations = []
  
  def self.masters
    where project_id: nil
  end
  
  def self.by_user user
    where user_id: user
  end
  
  def self.inherited subclass
    @@implementations << subclass
  end

  def self.implementations
    @@implementations
  end
  
  after_initialize do
    initialize_extension
  end
  
  def initialize_extension
    extend modul::Base
  end
  
  # Which time tracking module you will use.
  def tt_module
    mdl = read_attribute( :tt_module )
    mdl.present? ? mdl : master.try(:tt_module)
  end

  def modul
    m = tt_module || "TimeTrackingProjectStub"
    m.constantize
  end
  
  # Recursively sums up all stages' relative progress.
  def relative_progress
    if stages.any?
      from_stages = stages.collect{ |pr| pr.relative_progress }.sum
    end
    sum=(relative_milestone.to_f / milestones) * relative_expected_percentage
    sum + from_stages.to_f
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
  
  # Recursively sums up all invoices from the project and its stages.
  def charged_so_far
    charges = stages.collect{ |pr| pr.charged_so_far }.sum
    invoices.collect{ |inv| inv.total }.sum + charges
  end
  alias :total_charges :charged_so_far
  
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
  
  def duration_in_hours
    duration.to_f / 60 / 60
  end
  
  def per_hour_actual
    sum = total_charge_so_far / duration_in_hours
    sum.nan? ? 0.0 : sum
  end
  
  def per_hour_expected
    sum = quote / hours_expected.to_f
    sum.nan? ? 0.0 : sum
  end
  
  def expected_percentage
    read_attribute( :expected_percentage ).to_f
  end
  
  def total_expected_percentage
    stages.map{ |stage| stage.expected_percentage }.sum
  end
  
  def relative_expected_percentage
    total = master.try( :total_expected_percentage ).to_f
    total = 100.to_f if total < 100
    ( expected_percentage / total ) * 100.0
  end
  
  def hours_expected
    sum = read_attribute( :hours_expected ).to_f
    return sum unless sum.zero?
    master.try( :hours_expected ).to_f * relative_expected_percentage / 100.0
  end
  
  def per_milestone
    if stage?
      return 0.to_f if milestones == 1 and not completed
      for_stage = pre_finalised_quote * expected_percentage / 100.0
      for_stage / milestones
    end
  end
  
  def total_charge_so_far
    charged_so_far + next_charge
  end
  alias :standing_charge total_charge_so_far
  
  def remaining_charge
    quote - super_master.charged_so_far
  end
  
  def quote
    super_master? ? read_attribute( :quote ).to_f : super_master.quote
  end
  
  def after_finalised
    if super_master?
      read_attribute( :after_finalised ).to_f
    else
      super_master.after_finalised
    end
  end
  
  # Generates a new title for a project, like "New Project 17".
  def self.new_title
    match_str = /#{NEW_PROJECT_TITLE} (\d+)/i
    titles = pluck(:title).select{ |p| p =~ match_str }
    nums = titles.map{ |t| t.match( match_str )[1] }
    num = nums.sort!.reverse!.first.to_i
    "#{NEW_PROJECT_TITLE} #{num + 1}"
  end
  
  before_create do |project|
    project.title = self.class.new_title if project.title.blank?
  end
end

# This class is for the sake of having a "stand-in" project
# when there's no time-tracking module selected (like Toggl).
module TimeTrackingProjectStub
  # TODO: perhaps some class methods for TimeTrackingProjectStub?
  module Base
    def duration() 0 end
    def earned_on( date ) 0.to_f end
    def finish() start end
    def method_missing( method_name ) nil end
  end
end

