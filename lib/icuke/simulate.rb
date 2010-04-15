require 'json'

module ICuke
  module Simulate
    module Events
      class Event
        attr_reader :hold_for, :event_time, :options
        
        def initialize(options = {})
          @options = options
          @hold_for = options[:hold_for] || 0.2
          
          @event_time = self.class.event_time
          
          self.class.hold_for(hold_for)
        end
        
        def self.event_time
          @time.to_i
        end
        
        def self.hold_for(seconds)
          @time = @time.to_i + (seconds * 1_000_000_000)
        end
      end
      
      class Touch < Event
        GSEventHand = 3001
        GSTouchDown = 1
        GSTouchUp = 6
        GSTouchMoved = 2
        
        TYPE = {
          :down => GSTouchDown,
          :up => GSTouchUp,
          :moved => GSTouchMoved
        }.freeze
        
        attr_accessor :type, :paths
        
        def initialize(type, paths, options = {})
          super(options)
          
          @type = type
          @paths = paths
        end
        
        def averageX
          paths.inject(0) { |s,p| s + p[0] } / paths.size
        end
        
        def averageY
          paths.inject(0) { |s,p| s + p[1] } / paths.size
        end
        
        def to_json(*a)
          {
            'Type' => GSEventHand,
            'Time' => event_time,
            'WindowLocation' => { 'X' => averageX, 'Y' => averageY },
            'Data' => {
              'Delta' => { 'X' => paths.size, 'Y' => paths.size },
              'Type' => TYPE[type],
              'Paths' => paths.map { |p|
                {
                  'Location' => { 'X' => p[0], 'Y' => p[1] },
                  'Size' => { 'X' => 1.0, 'Y' => 1.0 }
                }
              }
            }
          }.to_json(*a)
        end
      end
    end

    module Gestures
      class Tap
        attr_accessor :x, :y, :options
        
        def initialize(x, y, options = {})
          @options = options
          
          @x = x
          @y = y
        end
        
        def to_json(*a)
          [
            ICuke::Simulate::Events::Touch.new(:down, [[x, y]], options),
            ICuke::Simulate::Events::Touch.new(:up, [[x, y]])
          ].to_json(*a)
        end
      end
      
      class Swipe
        attr_accessor :x, :y, :x2, :y2, :options
        
        def initialize(x, y, x2, y2, options)
          @options = options
          
          @x = x
          @y = y
          @x2 = x2
          @y2 = y2
        end
        
        def to_json(*a)
          events = [ICuke::Simulate::Events::Touch.new(:down, [[x, y]], options.merge(:hold_for => 0.015))]
          i, j = x, y
          while i < x2 or j < y2 do
            events << ICuke::Simulate::Events::Touch.new(:moved, [[i, j]], :hold_for => 0.015)
            i += 25 if i < x2
            j += 25 if j < y2
          end
          events << ICuke::Simulate::Events::Touch.new(:moved, [[x2, y2]], :hold_for => 0.015)
          events << ICuke::Simulate::Events::Touch.new(:up, [[x2, y2]], :hold_for => 0.015)
          events.to_json(*a)
        end
      end
    end
  end
end
