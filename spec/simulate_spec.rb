require 'spec/spec_helper'
require 'icuke'
require 'icuke/simulate'

describe ICuke::Simulate::Events::Touch do

  before(:each) do
    @touch = ICuke::Simulate::Events::Touch.new(:up, [[20, 30]])
  end

  it "should include the Location of the touch in the output" do
    @touch.to_json.should include '"Location":{"X":20,"Y":30}'
  end

  it "should include the proper event type in the output" do
    @touch.to_json.should include '"Type":3001'
  end

  it "should include the proper touch time (up/down)" do
    @touch.to_json.should include '"Type":6'
    @touch = ICuke::Simulate::Events::Touch.new(:down, [[20, 30]])
    @touch.to_json.should include '"Type":1'
  end

  it "should include the proper window location" do
    @touch.to_json.should include '"WindowLocation":{"X":20,"Y":30}'
  end
 
end

describe ICuke::Simulate::Gestures::Tap do

  it "should generate a down and up touch" do
    tap = ICuke::Simulate::Gestures::Tap.new(20, 30)
    tap.to_json.should include touch_output(1, 20, 30)
    tap.to_json.should include touch_output(6, 20, 30)
  end

end

describe ICuke::Simulate::Gestures::Swipe do

  before(:each) do
    @swipe = ICuke::Simulate::Gestures::Swipe.new(40, 60, 20, 30, 0.015, {})
  end

  it "should generate a down and up touch" do
    @swipe.to_json.should include touch_output(1, 40, 60)
    @swipe.to_json.should include touch_output(6, 20, 30)
  end

  it "should generate move touches" do
    move_x, move_y = calculate_move(40, 60, 20, 30, 1)
    @swipe.to_json.should include touch_output(2, move_x, move_y)
  end

  it "should generate multiple move touches when moving over distance" do
    mx1, my1 = calculate_move(40, 60, 120, 130, 1)
    @swipe = ICuke::Simulate::Gestures::Swipe.new(40, 60, 120, 130, 0.015, {})
    4.times do |i|
      x, y = calculate_move(40, 60, 120, 130, i+1)
      @swipe.to_json.should include touch_output(2, x, y)
    end
  end

  it "should include the appropriate hold_for value in the output" do
    times = timestamps(@swipe.to_json)
    times[0].should == times[1] - 15000000
  end
  
end




