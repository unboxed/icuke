require 'curb'
require 'nokogiri'

require 'icuke/simulator'
require 'icuke/simulate'

class ICukeWorld
  include ICuke::Simulate::Gestures
  
  BASE_URL = 'http://localhost:50000'
  
  attr_reader :response
  
  def initialize
    @simulator = ICuke::Simulator.new
  end
  
  def launch(application, options = {})
    @simulator.launch(application, options)
  end
  
  def quit
    @simulator.quit
  end
  
  def page
    @xml ||= Nokogiri::XML::Document.parse(response).root
  end
  
  def response
    @response ||= Curl::Easy.http_get(BASE_URL + '/view').body_str
  end
  
  def record
    Curl::Easy.http_get(BASE_URL + "/record")
  end
    
  def tap(label, pause = 1)
    unless frame = page.xpath(%Q{//*[@label="#{label}"]/frame}).first
      raise %Q{No element labelled "#{label}" found in: #{response}}
    end
    
    # Hit the element in the middle
    x = frame['x'].to_f + (frame['width'].to_f / 2)
    y = frame['y'].to_f + (frame['height'].to_f / 2)
    
    Curl::Easy.http_get(BASE_URL + "/event?json=#{Tap.new(x, y).to_json}")
    
    sleep(pause)
    
    refresh
  end
  
  def type(textfield, text)
    tap(textfield)
    text.split('').each do |c|
      tap(c.downcase, 0)
    end
    tap('Return')
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
         :env => { 'DYLD_INSERT_LIBRARIES' => File.expand_path(File.dirname(__FILE__) + '/../../ext/iCuke/libicuke.dylib') }
end

Then /^I should see "([^\"]*)"$/ do |text|
  if page.xpath("//*[contains(., '#{text}') or contains(@label, '#{text}') or contains(@value, '#{text}')]").empty?
    raise %Q{Content "#{text}" not found in: #{response}}
  end
end

When /^I tap "([^\"]*)"$/ do |label|
  tap(label)
end

When /^I type "([^\"]*)" in "([^\"]*)"$/ do |text, textfield|
  type(textfield, text)
end

Then /^I put the phone into recording mode$/ do
  record
end

Then /^show me the screen$/ do
  puts response
end

After do
  quit
end
