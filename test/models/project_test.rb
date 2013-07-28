require 'test_helper'

class ProjectTest < ActiveSupport::TestCase
  def setup
    @master = Project.find_by_title('Test Project')
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
  
  test "total charges" do
    assert_equal 1500, @master.total_charges
  end
  
  test "next charge" do
    assert_in_delta 650.to_f, @master.next_charge, 0.00001
  end
  
  test "test durations" do
    puts "\n#{@master.title} => #{ to_duration_string( @master.duration ) }"
    @master.stages.each do |stage|
      puts "#{stage.title} => #{to_duration_string( stage.duration )}"
    end
    assert_equal( 126_000, @master.duration )
    assert_equal( 54_000, @master.stages.first.duration )
    assert_equal( 61_200, @master.stages.second.duration )
  end
  
  test "test no tt_project at all" do
  end
  
  def to_duration_string duration
    mm, ss = duration.divmod(60)
    hh, mm = mm.divmod(60)
    "%d:%d:%d" % [hh, mm, ss]
  end
end
