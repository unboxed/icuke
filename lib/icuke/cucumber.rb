require 'curb'
require 'nokogiri'

require 'icuke/simulator'

class ICukeWorld
  BASE_URL = 'http://localhost:50000'
  
  attr_reader :response
  
  def initialize
    @simulator = ICuke::Simulator.new
  end
  
  def launch(application, options = {})
    @simulator.launch(application, options)
  end
  
  def page
    @xml ||= Nokogiri::XML::Document.parse(response).root
  end
  
  def response
    @response ||= Curl::Easy.http_get(BASE_URL + '/view').body_str
  end
  
  def touch(address)
    Curl::Easy.http_get(BASE_URL + "/touch/#{address}")
    
    sleep(1)
    
    refresh
  end
  
  private
  
  def refresh
    @response = nil
    @xml = nil
  end
end

World do
  ICukeWorld.new
end

Given /^"([^\"]*)" is loaded in the simulator(?: using sdk (.*))?$/ do |application, sdk|
  launch File.expand_path(application),
         :sdk => sdk,
         :env => { 'DYLD_INSERT_LIBRARIES' => '/Users/robholland/Development/Unboxed/icuke/lib/preload/iCuke/libicuke.dylib' }
end

Then /^I should see "([^\"]*)"$/ do |text|
  if page.xpath("//*[contains(., '#{text}')]").empty?
    raise %Q{Content "#{text}" not found}
  end
end

When /^I press "([^\"]*)"$/ do |text|
  xpaths = []
  xpaths << %Q{//*[accessibilityTrait[@trait="button"]][accessibilityLabel[contains(., '#{text}')]]/@address}
  xpaths << %Q{//UIView[subviews/UILabel/accessibilityLabel[contains(., '#{text}')]]/following-sibling::UBTextField/@address}
  xpaths << %Q{//UIView/subviews/UITextField[accessibilityLabel[contains(., '#{text}')]]/@address}
  xpaths << %Q{//UIView/subviews/UINavigationItemView[accessibilityLabel[contains(., '#{text}')]]/@address}
  xpaths << %Q{//UITableViewCell[text[contains(., '#{text}')]]/@address}
  unless element = page.xpath(*xpaths).first
    raise %Q{No element labelled "#{text}" found}
  end
  touch(element.text)
end

Then /^show me the screen$/ do
  puts response
end
