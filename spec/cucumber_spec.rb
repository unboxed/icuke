require 'spec/spec_helper'
require 'icuke'
require 'cucumber/step_mother'
require 'icuke/cucumber'
require 'icuke/simulate'


describe ICukeWorld do

  before(:each) do
    @simulator = []
    ICuke::Simulator.should_receive(:new).and_return(@simulator)
    @cuke_world = ICukeWorld.new
    @cuke_world.stub!(:sleep)
  end

  describe "when performing a swipe" do

    before(:each) do
      @simulator.should_receive(:fire_event)
    end
    
    it "should begin swipe at center of screen" do
      center_x, center_y = 160, 240
      ICuke::Simulate::Gestures::Swipe.should_receive(:new).
        with(center_x, center_y, 160, 480, 0.015, {})
      @cuke_world.swipe(:down)
    end

    it "should swipe to the bottom of the screen when swiping down" do
      bottom_y = 480
      ICuke::Simulate::Gestures::Swipe.should_receive(:new).
        with(160, 240, 160, bottom_y, 0.015, {})
      @cuke_world.swipe(:down)
    end

    it "should swipe to the top of the screen when swiping up" do
      top_y = 0
      ICuke::Simulate::Gestures::Swipe.should_receive(:new).
        with(160, 240, 160, top_y, 0.015, {})
      @cuke_world.swipe(:up)
    end

    it "should swipe to the left of the screen when swipping left" do
      min_x = 0
      ICuke::Simulate::Gestures::Swipe.should_receive(:new).
        with(160, 240, min_x, 240, 0.015, {})
      @cuke_world.swipe(:left)
    end

    it "should swipe to the right of the screen when swipping right" do
      max_x = 320
      ICuke::Simulate::Gestures::Swipe.should_receive(:new).
        with(160, 240, max_x, 240, 0.015, {})
      @cuke_world.swipe(:right)
    end
    
  end
  
  describe "when performing a drag" do

    before(:each) do
      @simulator.stub(:fire_event)
    end

    it "should fire an event" do
      @simulator.should_receive(:fire_event)
      @cuke_world.drag(1,2,3,4,{})
    end

    it "should simulate a swipe from source to destination" do
      sx, sy, dx, dy = 10, 20, 30, 40
      ICuke::Simulate::Gestures::Swipe.should_receive(:new).
        with(sx, sy, dx, dy, 0.1, {})
      @cuke_world.drag(sx, sy, dx, dy, {})
    end

    
    
  end
end
