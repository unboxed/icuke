require 'nokogiri'

require 'icuke/simulator'
require 'icuke/simulate'

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
    @xml ||= Nokogiri::XML::Document.parse(response).root
  end
  
  def response
    @response ||= @simulator.view
  end
  
  def record
    @simulator.record
  end
  
  def can_see?(text)
    page.xpath("//*[contains(., '#{text}') or contains(@label, '#{text}') or contains(@value, '#{text}')]").any?
  end
  
  def onscreen?(x, y)
    return x >= 0 && y >= 0 && x < 320 && y < 480
  end
  
  def tap(label, options = {}, &block)
    options = {
      :pause => true
    }.merge(options)
    
    element =
      page.xpath(
        %Q{//*[#{trait(:button, :updates_frequently, :keyboard_key)} and @label="#{label}" and frame]},
        %Q{//*[#{trait(:link)} and @value="#{label}" and frame]}
      ).first
    
    raise %Q{No element labelled "#{label}" found in: #{response}} unless element
    
    # This seems brittle, revist how to fetch the frame without relying on it being the only child
    frame = element.child
    
    # Hit the element in the middle
    x = frame['x'].to_f + (frame['width'].to_f / 2)
    y = frame['y'].to_f + (frame['height'].to_f / 2)
    
    raise %Q{Element "#{label}" is off screen in: #{response}} unless onscreen?(x, y)
    
    @simulator.fire_event(Tap.new(x, y, options))
    
    sleep(options[:pause] ? 1 : 0.2)
    
    refresh
    
    yield element if block_given?
  end
  
  def swipe(direction, options = {})
    modifier = [:up, :left].include?(direction) ? -1 : 1

    # Just swipe from the middle of an iPhone-dimensioned screen for now
    x = 320 / 2
    y = 480 / 2
    x2 = x
    y2 = y
    
    if [:up, :down].include?(direction)
      y2 = y + (100 * modifier)
    else
      x2 = x + (100 * modifier)
    end
    
    @simulator.fire_event(Swipe.new(x, y, x2, y2, options))
    
    sleep(1)
    
    refresh
  end
  
  def type(textfield, text, options = {})
    tap(textfield, :hold_for => 0.75) do |field|
      if field['value']
        tap('Select All')
        tap('Delete')
      end
    end
    
    text.split('').each do |c|
      next_keyboard_keys = ['shift', 'next keyboard', 'shift']
      
      begin
        tap(c, :pause => false)
      rescue Exception => e
        until next_keyboard_keys.empty?
          begin
            tap(next_keyboard_keys.shift, :pause => false)
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
    while page.xpath("//*[contains(., '#{text}') or contains(@label, '#{text}') or contains(@value, '#{text}')]").empty? do
      scroll(options[:direction])
      raise %Q{Content "#{text}" not found in: #{response}} if response == previous_response
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
  
  def trait(*traits)
    "(#{traits.map { |t| "contains(@traits, \"#{t}\")" }.join(' or ')})"
  end
  
  def refresh
    @response = nil
    @xml = nil
  end
end

World do
  ICukeWorld.new
end

LIBICUKE = File.expand_path(File.dirname(__FILE__) + '/../../ext/iCuke/libicuke.dylib')

Given /^(?:"([^\"]*)" from )?"([^\"]*)" is loaded in the simulator(?: using sdk (.*))?$/ do |target, project, sdk|
  launch File.expand_path(project),
         :target => target,
         :env => { 'DYLD_INSERT_LIBRARIES' => LIBICUKE }
end

Then /^I should see "([^\"]*)"$/ do |text|
  raise %Q{Content "#{text}" not found in: #{response}} unless can_see?(text)
end

Then /^I should not see "([^\"]*)"$/ do |text|
  raise %Q{Content "#{text}" was found but was not expected in: #{response}} if can_see?(text)
end

When /^I tap "([^\"]*)"$/ do |label|
  tap(label)
end

When /^I type "([^\"]*)" in "([^\"]*)"$/ do |text, textfield|
  type(textfield, text)
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
  puts response
end
