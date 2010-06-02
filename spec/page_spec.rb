require 'spec/spec_helper'
require 'icuke/page'

describe Page do
  before(:all) do
    @xml = File.read('spec/fixtures/controls_page.xml')
  end

  before(:each) do
    @page = Page.new(@xml)
  end
  
  context "when testing if an element exists" do
    
    it "should be able to search for a label" do
      @page.exists?("Customized Slider").should be_true
    end

    it "should be able to search for a label within a scope" do
      # why does this not work with any scope?
      @page.exists?("Customized Slider", "UIWindow").should be_true
    end

    it "should be able to search for a value" do
      @page.exists?("50%").should be_true
    end

    it "should be able to search for a node" do
      @page.exists?("UISlider").should be_true
    end

    it "should know when an element is visible on the screen" do
      @page.onscreen?("Standard Slider").should be_true
    end
    
  end

  context "when finding a tappable element" do

    it "should find an element with a button trait" do
      @page.first_tappable_element("Standard switch").name.should == "UISwitch"
    end

    it "should find an element with an updates_frequently trait" do
      @page.first_tappable_element("Custom").name.should == "UIAccessibilityElementMockView"
    end

    it "should find an element by its label" do
      @page.first_tappable_element("Customized Slider").name.should == "UILabel"
    end

    it "should raise an exception when the element is not found" do
      lambda{@page.first_tappable_element("does_not_exist")}.should raise_error
    end
    
  end

  context "when finding a slider element" do

    it "should find a slider by its label" do
      @page.first_slider_element("Standard slider").name.should == "UISlider"
    end

    it "should find a slider by a UILabel withing the same parent" do
      @page.first_slider_element("Standard Slider").name.should == "UISlider"
    end
    
    it "should raise an exception when the element is not found" do
      lambda{@page.first_slider_element("does_not_exist")}.should raise_error
    end
  
  end
  
end
