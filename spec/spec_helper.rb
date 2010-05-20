require 'rubygems'
require 'spec'

$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'icuke'
$:.unshift(File.dirname(__FILE__))


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
