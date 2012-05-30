require 'spec/spec_helper'
require 'icuke'
require 'cucumber/step_mother'
require 'icuke/cucumber'
require 'icuke/simulate'


describe ICukeWorld do

  before(:each) do
    @simulator = []
    @simulator.stub(:view)
    @simulator.stub(:fire_event)
    ICuke::Simulator.should_receive(:new).and_return(@simulator)
    @cuke_world = ICukeWorld.new
    @cuke_world.stub!(:sleep)
    xml = File.read('spec/fixtures/controls_page.xml')
    @cuke_world.stub(:response).and_return(xml)
  end

  context "when performing a swipe" do

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
  
  context "when performing a drag" do

    it "should fire an event" do
      @simulator.should_receive(:fire_event)
      @cuke_world.drag(1,2,3,4,{})
    end

    it "should simulate a swipe from source to destination" do
      sx, sy, dx, dy = 10, 20, 30, 40
      ICuke::Simulate::Gestures::Drag.should_receive(:new).
        with(sx, sy, dx, dy, 0.15, {})
      @cuke_world.drag(sx, sy, dx, dy, {})
    end

  end
  
  context "when performing a drag with a source" do

    it "should parse the input values" do
      ICuke::Simulate::Gestures::Drag.should_receive(:new).
        with(12, 24, 34, 44, 0.15, {})
      @cuke_world.drag_with_source("12,24", "34,44")
    end
    
  end

  context "when draging a slider" do
    
    before(:each) do
      @screen = []
      @screen.should_receive(:first_slider_element).at_least(:once)
      @screen.should_receive(:find_slider_button).at_least(:once).and_return([244, 287])
      Screen.should_receive(:new).at_least(:once).and_return(@screen)
    end

    it "should set the destination properly" do
      {:up=>[244,267], :down=>[244,307], :right=>[264,287], :left=>[224,287]}.each do |d|
        ICuke::Simulate::Gestures::Drag.should_receive(:new).
          with(244, 287, d[1][0], d[1][1], 0.15, {})
        @cuke_world.drag_slider_to('Label', d[0], 20)
      end
    end

  end

  context "when draging a slider to a percentage value" do
    
    before(:each) do
      @element = []
      @screen = []
      @screen.should_receive(:first_slider_element).and_return(@element)
      @screen.should_receive(:find_slider_button).and_return([244, 287])
      Screen.should_receive(:new).and_return(@screen)
    end

    it "should identify the destination on the screen" do
      @screen.should_receive(:find_slider_percentage_location).with(@element, 30).
        and_return([230, 287])
      ICuke::Simulate::Gestures::Drag.should_receive(:new).
        with(244, 287, 230, 287, 0.15, {})
      @cuke_world.drag_slider_to_percentage("label", 30)
    end
    
  end
end
