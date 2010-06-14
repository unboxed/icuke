require 'spec/spec_helper'
require 'icuke/screen'

describe Screen do
  before(:all) do
    @xml = File.read('spec/fixtures/controls_page.xml')
  end

  before(:each) do
    @screen = Screen.new(@xml)
  end
  
  context "when testing if an element exists" do
    
    it "should be able to search for a label" do
      @screen.exists?("Customized Slider").should be_true
    end

    it "should be able to search for a label within a scope" do
      # why does this not work with any scope?
      @screen.exists?("Customized Slider", "UIWindow").should be_true
    end

    it "should be able to search for a value" do
      @screen.exists?("50%").should be_true
    end

    it "should be able to search for a node" do
      @screen.exists?("UISlider").should be_true
    end

    it "should know when an element is visible on the screen" do
      @screen.visible?("Standard Slider").should be_true
    end
    
  end

  context "when finding a tappable element" do

    it "should find an element with a button trait" do
      @screen.first_tappable_element("Standard switch").name.should == "UISwitch"
    end

    it "should find an element with an updates_frequently trait" do
      @screen.first_tappable_element("Custom").name.should == "UIAccessibilityElementMockView"
    end

    it "should find an element by its label" do
      @screen.first_tappable_element("Customized Slider").name.should == "UILabel"
    end

    it "should raise an exception when the element is not found" do
      lambda{@screen.first_tappable_element("does_not_exist")}.should raise_error
    end
    
  end

  context "when finding a slider element" do

    it "should find a slider by its label" do
      @screen.first_slider_element("Standard slider").name.should == "UISlider"
    end

    it "should find a slider by a UILabel withing the same parent" do
      @screen.first_slider_element("Standard Slider").name.should == "UISlider"
    end
    
    it "should raise an exception when the element is not found" do
      lambda{@screen.first_slider_element("does_not_exist")}.should raise_error
    end
  
  end

  context "when finding the button for a slider" do
    
    before(:each) do
      @frame = {}
      @element = {}
      @element.should_receive(:child).at_least(:once).and_return(@frame)
    end

    it "should find coordinates when slider is horizontal" do
      set_frame_values(184,275,120,24)
      {'50%' => 244, '100%' => 294, '75%' =>  269, '25%' => 219, '0%' => 194}.each do |v|
        @element['value'] = v[0]
        x, y = @screen.find_slider_button(@element)
        x.should == v[1]
        y.should == 287
      end
    end

    it "should find coordinates when slider is vertical" do
      set_frame_values(184,175,24,120)
      {'50%' => 235, '100%' => 285, '75%' =>  260,'25%' => 210, '0%' => 185}.each do |v|
        @element['value'] = v[0]
        x,y = @screen.find_slider_button(@element)
        x.should == 196
        y.should == v[1]
      end
    end

  end

  context "when finding a location corresponding to a percentage for a slider" do
    
    before(:each) do
      @frame = {}
      @element = {}
      @element.should_receive(:child).at_least(:once).and_return(@frame)
    end

    it "should find percentage coordinate when slider is horizontal" do
      set_frame_values(184,275,120,24)
      {50 => 244, 100 => 294, 75 => 269, 25 => 219, 0 => 194}.each do |v|
        x,y = @screen.find_slider_percentage_location(@element, v[0])
        x.should == v[1]
        y.should == 287
      end
    end

    it "should find percentage coordinate when slider is vertical" do
      set_frame_values(184,175,24,120)
      {50 => 235, 100 => 285, 75 =>  260, 25 => 210, 0 => 185}.each do |v|
        x,y = @screen.find_slider_percentage_location(@element, v[0])
        x.should == 196
        y.should == v[1]
      end
    end
    
  end

  context "when finding the coordinates for a swipe" do

    it "should start the coordinates with the center of the screen" do
      x,y,x2,y2 = @screen.swipe_coordinates(:down)
      x.should == 160
      y.should == 240
    end

    it "should end the swipe at the top center when swiping up" do
      x,y,x2,y2 = @screen.swipe_coordinates(:up)
      x2.should == 160
      y2.should == 0
    end

    it "should end the swipe at the bottom center when swiping down" do
      x,y,x2,y2 = @screen.swipe_coordinates(:down)
      x2.should == 160
      y2.should == 480
    end

    it "should end the swipe at the right center when swiping right" do
      x,y,x2,y2 = @screen.swipe_coordinates(:right)
      x2.should == 320
      y2.should == 240
    end

    it "should end the swipe at the left center when swiping left" do
      x,y,x2,y2 = @screen.swipe_coordinates(:left)
      x2.should == 0
      y2.should == 240
    end
        
  end
  
  def set_frame_values(x, y, width, height)
    @frame['x'] = x
    @frame['y'] = y
    @frame['width'] = width
    @frame['height'] = height
  end

end
