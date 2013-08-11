module ProjectsHelper
  def percent_of stage
    "#{stage.relative_progress.to_i}/#{stage.expected_percentage.to_i}%"
  end
  def hours_of project
    "#{project.duration_in_hours.round} hrs (expected #{project.hours_expected.round})"
  end
end
