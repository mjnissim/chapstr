require 'test_helper'

class ProjectTest < ActiveSupport::TestCase
  def setup
    @master = Project.find_by_title('Test Project')
  end
  
  test "throw exception when wrong api key for toggl" do
    com = Toggl::Communicator.new( "Testing_Authentication_with_Ruby_thats_all" )
    assert_raise Exceptions::AuthenticationError do
      com.workspace_id
    end
  end
  
  test "gets toggl projects list (means it can communicate with toggl)" do
    com = Toggl::Communicator.new( ENV['TOGGL_API_KEY'] )
    assert_not_nil ( plist = com.projects_list )
    puts "Printing the projects list (a hash)... :"
    puts plist
  end
    
  test "number of projects" do
    assert Project.count == 3
  end
  
  test "master has two stages" do
    assert_equal 2, @master.stages.count
  end

  test "relative progress" do
    assert_equal 50.0, @master.relative_progress
  end
  # 
  # test "total charges" do
  #   assert_equal 1500, @master.total_charges
  # end
  # 
  # test "next charge" do
  #   assert_in_delta 650.to_f, @master.next_charge, 0.00001
  # end
  # 
  # test "durations" do
  #   # puts "\n#{@master.title} => #{ to_duration_string( @master.duration ) }"
  #   # @master.stages.each do |stage|
  #   #   puts "#{stage.title} => #{to_duration_string( stage.duration )}"
  #   # end
  #   assert_equal( 126_000, @master.duration )
  #   assert_equal( 54_000, @master.stages.first.duration )
  #   assert_equal( 61_200, @master.stages.second.duration )
  # end
  # 
  # test "no module at all" do
  #   assert_nothing_raised do
  #     p = Project.new( title: "Test 87465" )
  #     p.relative_progress
  #   end
  # end
  # 
  # test "Toggl with invalid project id" do
  # end

end
