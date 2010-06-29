require 'icuke/simulator'
require 'icuke/simulate'
require 'icuke/screen'
require 'icuke/configuration'

module ICuke
  class SimulatorDriver
    include ICuke::Simulate::Gestures
    
    def initialize(simulator, configuration)
      @simulator = simulator
      @configuration = configuration
    end
    
    def self.default_driver(configuration)
      new(ICuke::Simulator.new, configuration)
    end
    
    def launch(application, options = {})
      default_options = {:build_configuration => configuration[:build_configuration]}
      process = ICuke::Simulator::Process.new(application, default_options.merge(options))
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

      sleep(options[:pause] ? 2 : 0.2)

      refresh

      yield element if block_given?
    end

    def swipe(direction, options = {})
      x, y, x2, y2 = screen.swipe_coordinates(direction)
      @simulator.fire_event(Swipe.new(x, y, x2, y2, 0.015, options))
      sleep(1)
      refresh
    end

    def drag(source_x, source_y, dest_x, dest_y, options = {})
      @simulator.fire_event(Drag.new(source_x, source_y, dest_x, dest_y, 0.15, options))
      sleep(1)
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
      x, y, x2, y2 = screen.swipe_coordinates(swipe_direction(options[:direction]))
      previous_response = response.dup
      until screen.visible?(text) do
        @simulator.fire_event(Swipe.new(x, y, x2, y2, 0.15, options))
        refresh
        raise %Q{Content "#{text}" not found in: #{screen}} if response == previous_response
      end
    end

    def scroll(direction)
      swipe(swipe_direction(direction))
    end

    def set_application_defaults(defaults)
      @simulator.set_defaults(defaults)
    end
    
    def refresh
      @response = nil
      @screen = nil
    end

    private

    def swipe_direction(direction)
      swipe_directions = { :up => :down, :down => :up, :left => :right, :right => :left }
      swipe_directions[direction]
    end

    def direction_modifier(direction)
      [:up, :left].include?(direction) ? -1 : 1
    end
    
    def configuration
      @configuration
    end
  end
end
