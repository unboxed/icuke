require 'json'

module ICuke
  module Simulate
    module Events
      class Event
        def self.event_time
          @time = @time.to_i + 1
        end
        
        def event_time
          self.class.event_time
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
        
        def initialize(type, paths)
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
        attr_accessor :x, :y
        
        def initialize(x, y)
          @x = x
          @y = y
        end
        
        def to_json(*a)
          [
            ICuke::Simulate::Events::Touch.new(:down, [[x, y]]),
            ICuke::Simulate::Events::Touch.new(:up, [[x, y]])
          ].to_json(*a)
        end
      end
    end
  end
end
