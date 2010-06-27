require 'nokogiri'

require 'icuke/sdk'
require 'icuke/simulator_driver'

class ICukeWorld
  def simulator_driver
    @simulator_driver ||= ICuke::SimulatorDriver.default_driver(configuration)
  end
  
  def self.configure(&block)
    configuration.instance_eval(&block)
  end
  
  def self.configuration
    @configuration ||= ICuke::Configuration.new({
      :build_configuration => 'Debug'
    })
  end
  
  def configuration
    self.class.configuration
  end
end

World do
  ICukeWorld.new
end

After do
  simulator_driver.quit
end

Given /^(?:"([^\"]*)" from )?"([^\"]*)" is loaded in the (?:(iphone|ipad) )?simulator(?: with SDK ([0-9.]+))?$/ do |target, project, platform, sdk_version|
  if sdk_version
    ICuke::SDK.use(sdk_version)
  elsif platform
    ICuke::SDK.use_latest(platform.downcase.to_sym)
  else
    ICuke::SDK.use_latest
  end
  
  simulator_driver.launch File.expand_path(project),
         :target => target,
         :platform => platform,
         :env => {
           'DYLD_INSERT_LIBRARIES' => ICuke::SDK.dylib_fullpath
         }
end

Given /^the module "([^\"]*)" is loaded in the simulator$/ do |path|
  path.sub!(/#{File.basename(path)}$/, ICuke::SDK.dylib(File.basename(path)))
  simulator.load_module(File.expand_path(path))
end

Then /^I should see "([^\"]*)"(?: within "([^\"]*)")?$/ do |text, scope|
  raise %Q{Content "#{text}" not found in: #{screen.xml}} unless simulator_driver.screen.visible?(text, scope)
end

Then /^I should not see "([^\"]*)"(?: within "([^\"]*)")?$/ do |text, scope|
  raise %Q{Content "#{text}" was found but was not expected in: #{screen.xml}} if simulator_driver.screen.visible?(text, scope)
end

When /^I tap "([^\"]*)"$/ do |label|
  simulator_driver.tap(label)
end

When /^I type "([^\"]*)" in "([^\"]*)"$/ do |text, textfield|
  simulator_driver.type(textfield, text)
end

When /^I drag from (.*) to (.*)$/ do |source, destination|
  simulator_driver.drag_with_source(source, destination)
end

When /^I select the "(.*)" slider and drag (.*) pixels (down|up|left|right)$/ do |label, distance, direction|
  simulator_driver.drag_slider_to(label, direction.to_sym, distance.to_i)
end

When /^I move the "([^\"]*)" slider to (.*) percent$/ do |label, percent|
  simulator_driver.drag_slider_to_percentage(label, percent.to_i)
end

When /^I scroll (down|up|left|right)(?: to "([^\"]*)")?$/ do |direction, text|
  if text
    simulator_driver.scroll_to(text, :direction => direction.to_sym)
  else
    simulator_driver.scroll(direction.to_sym)
  end
end

When /^I suspend the application/ do
  simulator_driver.suspend
end

When /^I resume the application/ do
  simulator_driver.resume
end

Then /^I put the phone into recording mode$/ do
  simulator_driver.record
end

Then /^show me the screen$/ do
  puts simulator_driver.screen.xml.to_s
end
