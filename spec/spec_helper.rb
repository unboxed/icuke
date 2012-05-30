require 'rubygems'

$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'icuke'
$:.unshift(File.dirname(__FILE__))

begin
  require 'rspec'
  require 'rspec/autorun'
  Rspec.configure do |c|
    c.color_enabled = true
    c.before(:each) do
      ::Term::ANSIColor.coloring = true
    end
  end
rescue LoadError
  require 'spec'
  require 'spec/autorun'
  Spec::Runner.configure do |c|
    c.before(:each) do
      ::Term::ANSIColor.coloring = true
    end
  end
end

require 'cucumber'


def calculate_move(x1, y1, x2, y2, step_num)
  dx = x2 - x1
  dy = y2 - y1
  hypotenuse = Math.sqrt(dx*dx + dy*dy)
  step = 25 / hypotenuse
  return 40 + step_num * step * dx, 60 + step_num * step * dy
end

def touch_output(type, x, y)
  '{"Data":{"Paths":[{"Size":{"X":1.0,"Y":1.0},"Location":{"X":' +
    x.to_s +
    ',"Y":' +
    y.to_s +
    '}}],"Delta":{"X":1,"Y":1},"Type":' +
    type.to_s +
    '}'
end

def timestamps(json)
  segments = json.split('"Time":')
  segments.delete_at 0
  timestamps = []
  segments.each do |segment|
    timestamps << segment.split(',')[0].to_i
  end
  timestamps
end


def World
end
def After
end
def Given(something)
end
def When(something)
end
def Then(something)
end
