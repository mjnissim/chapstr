class UserIdNotNull < ActiveRecord::Migration
  def change
    # Make sure no null value exist
    Project.update_all({:user_id => User.first}, {:user_id => nil})

    # Change the column to not allow null
    change_column :projects, :user_id, :integer, :null => false
  end
end
