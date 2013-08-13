module ProjectsHelper
  def percent_of stage
    "#{stage.relative_progress.to_i}/#{stage.expected_percentage.to_i}%"
  end
  
  def hours_of project
    "#{project.duration_in_hours.round} hrs (expected #{project.hours_expected.round})"
  end
  
  def link_to_modal_form project
    link_to "##{ idify( project ) }", :class => 'btn btn-mini btn-warning',
        :'data-toggle' => "modal", :role=>"button" do
      content_tag( :i, nil, :class => "icon-wrench" ) +
      " Setup your project"
    end
  end
  
  def idify project
    project.title.parameterize.camelize(:lower)
  end
  
  def last_earned project
    "#{ nice_price( project.earned_on( project.last_date ) ) } NIS"
  end
end
