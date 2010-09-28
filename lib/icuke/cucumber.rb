require 'nokogiri'

require 'icuke/sdk'
require 'icuke/simulator'
require 'icuke/simulate'
require 'icuke/screen'

class ICukeWorld
  include ICuke::Simulate::Gestures
  
  attr_reader :response, :simulator
  
  def initialize
    @simulator = ICuke::Simulator.new
  end
  
  def launch(application, options = {})
    process = ICuke::Simulator::Process.new(application, options)
    @simulator.launch(process)
  end
  
  def quit
    @simulator.quit
  end
  
  def suspend
    @simulator.suspend
  end
  
  def resume
    @simulator.resume
  end
  
  def screen
    @screen ||= Screen.new(response)
  end
  
  def response
    @response ||= @simulator.view
  end
  
  def record
    @simulator.record
  end
  
  def tap(label, options = {}, &block)
    options = {
      :pause => true
    }.merge(options)
    
    element = screen.first_tappable_element(label)
    x, y = screen.element_center(element)
    
    @simulator.fire_event(Tap.new(x, y, options))
    
    sleep(options[:pause] ? 0.75 : 0.2)
    
    refresh
    
    yield element if block_given?
  end
  
  def swipe(direction, options = {})
    x, y, x2, y2 = screen.swipe_coordinates(direction)
    @simulator.fire_event(Swipe.new(x, y, x2, y2, 0.015, options))
    refresh
  end

  def drag(source_x, source_y, dest_x, dest_y, options = {})
    @simulator.fire_event(Drag.new(source_x, source_y, dest_x, dest_y, 0.15, options))
    refresh
  end

  def drag_with_source(source, destination)
    sources = source.split(',').collect {|val| val.strip.to_i}
    destinations = destination.split(',').collect {|val| val.strip.to_i}
    drag(sources[0], sources[1], destinations[0], destinations[1])
  end
  
  def drag_slider_to(label, direction, distance)
    element = screen.first_slider_element(label)
    x, y = screen.find_slider_button(element)
    
    dest_x, dest_y = x, y
    modifier = direction_modifier(direction)
    
    if [:up, :down].include?(direction)
      dest_y += modifier * distance
    else
      dest_x += modifier * distance
    end
    
    drag(x, y, dest_x, dest_y)
  end

  def drag_slider_to_percentage(label, percentage)
    element = screen.first_slider_element(label)
    x, y = screen.find_slider_button(element)
    dest_x, dest_y = screen.find_slider_percentage_location(element, percentage)
    drag(x, y, dest_x, dest_y)
  end

  def type(textfield, text, options = {})
    tap(textfield, :hold_for => 0.75) do |field|
      if field['value']
        tap('Select All')
        tap('Delete')
      end
    end
    
    # Without this sleep fields which have auto-capitilisation/correction can
    # miss the first keystroke for some reason.
    sleep(0.3)
    
    text.split('').each do |c|
      begin
        tap(c == ' ' ? 'space' : c, :pause => false)
      rescue Exception => e
        try_keyboards =
          case c
          when /[a-zA-Z]/
            ['more, letters', 'shift']
          when /[0-9]/
            ['more, numbers']
          else
            ['more, numbers', 'more, symbols']
          end
        until try_keyboards.empty?
          begin
            tap(try_keyboards.shift, :pause => false)
            retry
          rescue
          end
        end
        raise e
      end
    end

    # From UIReturnKeyType
    # Should probably sort these in rough order of likelyhood?
    return_keys = ['return', 'go', 'google', 'join', 'next', 'route', 'search', 'send', 'yahoo', 'done', 'emergency call']
    return_keys.each do |key|
      begin
        tap(key)
        return
      rescue
      end
    end
  end
  
  def scroll_to(text, options = {})
    previous_response = response.dup
    until screen.visible?(text) do
      scroll(options[:direction])
      raise %Q{Content "#{text}" not found in: #{screen}} if response == previous_response
    end
  end
  
  def scroll(direction)
    x, y, x2, y2 = screen.swipe_coordinates(swipe_direction(direction))
    @simulator.fire_event(Swipe.new(x, y, x2, y2, 0.12, {}))
    refresh
  end
  
  def set_application_defaults(defaults)
    @simulator.set_defaults(defaults)
  end
  
  private
  
  def refresh
    @response = nil
    @screen = nil
  end

  def swipe_direction(direction)
    swipe_directions = { :up => :down, :down => :up, :left => :right, :right => :left }
    swipe_directions[direction]
  end

  def direction_modifier(direction)
    [:up, :left].include?(direction) ? -1 : 1
  end

end

World do
  ICukeWorld.new
end

After do
  quit
end

Given /^(?:"([^\"]*)" from )?"([^\"]*)" is loaded in the (?:(iphone|ipad) )?simulator(?: with SDK ([0-9.]+))?$/ do |target, project, platform, sdk_version|
  if sdk_version
    ICuke::SDK.use(sdk_version)
  elsif platform
    ICuke::SDK.use_latest(platform.downcase.to_sym)
  else
    ICuke::SDK.use_latest
  end
  
  launch File.expand_path(project),
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
  raise %Q{Content "#{text}" not found in: #{screen.xml}} unless screen.visible?(text, scope)
end

Then /^I should not see "([^\"]*)"(?: within "([^\"]*)")?$/ do |text, scope|
  raise %Q{Content "#{text}" was found but was not expected in: #{screen.xml}} if screen.visible?(text, scope)
end

When /^I tap "([^\"]*)"$/ do |label|
  tap(label)
end

When /^I type "([^\"]*)" in "([^\"]*)"$/ do |text, textfield|
  type(textfield, text)
end

When /^I drag from (.*) to (.*)$/ do |source, destination|
  drag_with_source(source, destination)
end

When /^I select the "(.*)" slider and drag (.*) pixels (down|up|left|right)$/ do |label, distance, direction|
  drag_slider_to(label, direction.to_sym, distance.to_i)
end

When /^I move the "([^\"]*)" slider to (.*) percent$/ do |label, percent|
  drag_slider_to_percentage(label, percent.to_i)
end

When /^I scroll (down|up|left|right)(?: to "([^\"]*)")?$/ do |direction, text|
  if text
    scroll_to(text, :direction => direction.to_sym)
  else
    scroll(direction.to_sym)
  end
end

When /^I suspend the application/ do
  suspend
end

When /^I resume the application/ do
  resume
end

Then /^I put the phone into recording mode$/ do
  record
end

Then /^show me the screen$/ do
  puts screen.xml.to_s
end
