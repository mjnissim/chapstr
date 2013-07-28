require 'test_helper'

class ProjectsControllerTest < ActionController::TestCase
  setup do
    @project = projects(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:projects)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create project" do
    assert_difference('Project.count') do
      post :create, project: { after_finalised: @project.after_finalised, comments: @project.comments, completed: @project.completed, date_ended: @project.date_ended, date_started: @project.date_started, expected_percentage: @project.expected_percentage, finalised: @project.finalised, finish: @project.finish, hours_expected: @project.hours_expected, hours_so_far: @project.hours_so_far, milestone: @project.milestone, milestone_label: @project.milestone_label, per_hour: @project.per_hour, project_id: @project.project_id, quote: @project.quote, start: @project.start, title: @project.title, tt_module: @project.tt_module, tt_project_id: @project.tt_project_id }
    end

    assert_redirected_to project_path(assigns(:project))
  end

  test "should show project" do
    get :show, id: @project
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @project
    assert_response :success
  end

  test "should update project" do
    patch :update, id: @project, project: { after_finalised: @project.after_finalised, comments: @project.comments, completed: @project.completed, date_ended: @project.date_ended, date_started: @project.date_started, expected_percentage: @project.expected_percentage, finalised: @project.finalised, finish: @project.finish, hours_expected: @project.hours_expected, hours_so_far: @project.hours_so_far, milestone: @project.milestone, milestone_label: @project.milestone_label, per_hour: @project.per_hour, project_id: @project.project_id, quote: @project.quote, start: @project.start, title: @project.title, tt_module: @project.tt_module, tt_project_id: @project.tt_project_id }
    assert_redirected_to project_path(assigns(:project))
  end

  test "should destroy project" do
    assert_difference('Project.count', -1) do
      delete :destroy, id: @project
    end

    assert_redirected_to projects_path
  end
end
