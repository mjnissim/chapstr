class CreateProjects < ActiveRecord::Migration
  def change
    create_table :projects do |t|
      t.string :title
      t.integer :start
      t.integer :finish
      t.decimal :quote
      t.decimal :per_hour
      t.integer :expected_percentage
      t.integer :hours_so_far
      t.integer :hours_expected
      t.integer :milestone
      t.string :milestone_label
      t.date :date_started
      t.date :date_ended
      t.boolean :completed
      t.decimal :after_finalised
      t.boolean :finalised
      t.integer :project_id
      t.string :tt_module
      t.integer :tt_project_id
      t.text :comments

      t.timestamps
    end
  end
end
