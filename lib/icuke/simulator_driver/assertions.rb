require 'icuke/simulator_driver'
require 'test/unit/assertions'

module ICuke
  class SimulatorDriver
    module Assertions
      include Test::Unit::Assertions
      
      def assert_text_on_screen(text)
        assert_text_on_screen_with_scope(text, '')
      end
      
      def assert_text_on_screen_with_scope(text, scope)
        assert screen.visible?(text, scope),
         "Expected to find #{text} in scope #{scope}, #{screen.xml}"
      end
    end
    
    include Assertions
  end
end
