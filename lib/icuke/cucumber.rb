require 'nokogiri'

require 'icuke/simulator'
require 'icuke/simulate'
require 'icuke/page'

class ICukeWorld
  include ICuke::Simulate::Gestures
  
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
    @page ||= Page.new(response)
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
    
    element = page.first_tappable_element(label)
    x, y = page.element_position(element)
    
    @simulator.fire_event(Tap.new(x, y, options))
    
    sleep(options[:pause] ? 2 : 0.2)
    
    refresh
    
    yield element if block_given?
  end
  
  def swipe(direction, options = {})
    modifier = direction_modifier(direction)
    
    # Just swipe from the middle of an iPhone-dimensioned screen for now
    x = 320 / 2
    y = 480 / 2
    x2 = x
    y2 = y
    
    if [:up, :down].include?(direction)
      y2 = y + (y * modifier)
    else
      x2 = x + (x * modifier)
    end
    
    @simulator.fire_event(Swipe.new(x, y, x2, y2, 0.015, options))
    sleep(1)
    refresh
  end

  def drag(source_x, source_y, dest_x, dest_y, options = {})
    @simulator.fire_event(Swipe.new(source_x, source_y, dest_x, dest_y, 0.15, options))
    sleep(1)
    refresh
  end

  def drag_with_source(source, destination)
    sources = source.split(',').collect {|val| val.strip.to_i}
    destinations = destination.split(',').collect {|val| val.strip.to_i}
    drag(sources[0], sources[1], destinations[0], destinations[1])
  end
  
  def drag_slider_to(label, direction, distance)
    element = page.first_slider_element(label)
    x, y = page.find_slider_button(element)
    
    dest_x, dest_y = x, y
    modifier = direction_modifier(direction)
    
    if [:up, :down].include?(direction)
      dest_y += modifier * distance
    else
      dest_x += modifier * distance
    end
    
    drag(x,y,dest_x,dest_y)
  end

  def drag_slider_to_percentage(label, percentage)
    element = page.first_slider_element(label)
    x, y = page.find_slider_button(element)
    dest_x, dest_y = page.find_slider_percentage_location(element, percentage)
    drag(x,y,dest_x,dest_y)
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
    sleep(0.5)
    
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
    while not page.onscreen?(text) do
      scroll(options[:direction])
      raise %Q{Content "#{text}" not found in: #{page}} if response == previous_response
    end
  end
  
  def scroll(direction)
    swipe_directions = { :up => :down, :down => :up, :left => :right, :right => :left }
    swipe(swipe_directions[direction])
  end
  
  def set_application_defaults(defaults)
    @simulator.set_defaults(defaults)
  end
  
  private
  
  def refresh
    @response = nil
    @page = nil
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

LIBICUKE = File.expand_path(File.dirname(__FILE__) + '/../../ext/iCuke/libicuke.dylib')

Given /^(?:"([^\"]*)" from )?"([^\"]*)" is loaded in the simulator(?: using sdk (.*))?$/ do |target, project, sdk|
  launch File.expand_path(project),
         :target => target,
         :env => { 'DYLD_INSERT_LIBRARIES' => LIBICUKE }
end

Then /^I should see "([^\"]*)"(?: within "([^\"]*)")?$/ do |text, scope|
  raise %Q{Content "#{text}" not found in: #{page}} unless page.exists?(text, scope)
end

Then /^I should not see "([^\"]*)"(?: within "([^\"]*)")?$/ do |text, scope|
  raise %Q{Content "#{text}" was found but was not expected in: #{page}} if page.exists?(text, scope)
end

When /^I tap "([^\"]*)"$/ do |label|
  tap(label)
end

When /^I type "([^\"]*)" in "([^\"]*)"$/ do |text, textfield|
  type(textfield, text)
end

When /^I drag from ([^\"]*) to ([^\"]*)$/ do |source, destination|
  drag_with_source(source, destination)
end

When /^I select the "([^\"]*)" slider and drag ([^\"]*) pixels (down|up|left|right)$/ do |label, distance, direction|
  drag_slider_to(label, direction.to_sym, distance.to_i)
end

When /^I move the "([^\"]*)" slider to ([^\"]*) percent$/ do |label, percent|
  drag_slider_to_percentage(label, percent.to_i)
end

When /^I scroll (down|up|left|right)(?: to "([^\"]*)")?$/ do |direction, text|
  if text
    scroll_to(text, :direction => direction.to_sym)
  else
    scroll(direction.to_sym)
  end
end

Then /^I put the phone into recording mode$/ do
  record
end

Then /^show me the screen$/ do
  puts page.xml.to_s
end
