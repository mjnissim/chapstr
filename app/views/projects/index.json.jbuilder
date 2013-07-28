json.array!(@projects) do |project|
  json.extract! project, :title, :start, :finish, :quote, :per_hour, :expected_percentage, :hours_so_far, :hours_expected, :milestone, :milestone_label, :date_started, :date_ended, :completed, :after_finalised, :finalised, :project_id, :tt_module, :tt_project_id, :comments
  json.url project_url(project, format: :json)
end
