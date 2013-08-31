class Invoice < ActiveRecord::Base
  belongs_to :project
  has_one :user, through: :project
  
  def self.by_user user
    joins(:project).where(projects: {user_id: user.id})
  end
end
