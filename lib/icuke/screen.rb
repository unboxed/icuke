require 'nokogiri'

class Screen
  attr_reader :xml, :x, :y, :width, :height
  
  def initialize(xml)
    @xml = Nokogiri::XML::Document.parse(xml).root
    frame = @xml.at_xpath('/screen/frame')
    @x, @y = frame['x'].to_f, frame['y'].to_f
    @width, @height = frame['width'].to_f, frame['height'].to_f
  end
  
  def exists?(text, scope = '')
    find_element(text, scope).any?
  end
  
  def visible?(text, scope='')
    find_element(text, scope).each do |element|
      _x, _y = element_center(element)
      return true if _x >= self.x && _y >= self.y && _x < self.width && _y < self.height
    end
    return false
  end
  
  def element_center(element)
    frame = element.at_xpath('./frame')
    
    x = frame['x'].to_f
    y = frame['y'].to_f
    
    x += (frame['width'].to_f / 2)
    y += (frame['height'].to_f / 2)
    
    return x, y
  end

  def first_tappable_element(label)
    element =
      @xml.xpath(
        %Q{//*[#{trait(:button, :updates_frequently, :keyboard_key)} and @label="#{label}" and frame]},
        %Q{//*[#{trait(:link)} and @value="#{label}" and frame]},
        %Q{//*[@label="#{label}" and frame]}
      ).first
    raise %Q{No element labelled "#{label}" found in: #{@xml}} unless element
    element
  end

  def first_slider_element(label)
    element =
      @xml.xpath(
        %Q{//UISlider[@label="#{label}" and frame]},
        %Q{//*[@label="#{label}"]/../UISlider}
      ).first
    raise %Q{No element labelled "#{label}" found in: #{@xml}} unless element
    element
  end

  def find_slider_button(element)
    percentage = 0.01 * element['value'].to_f
    calculate_percentage_with_adjustment(element.child, percentage)
  end

  def find_slider_percentage_location(element, percentage)
    percentage = 0.01 * percentage
    calculate_percentage_with_adjustment(element.child, percentage)
  end
  
  def center_coordinates
    @center ||= element_center(@xml.at_xpath('/screen'))
  end

  def swipe_coordinates(direction)
    modifier = [:up, :left].include?(direction) ? -1 : 1
    x, y = center_coordinates
    x2, y2 = x, y
    if [:up, :down].include?(direction)
      y2 = y + (y * modifier)
    else
      x2 = x + (x * modifier)
    end
    return x, y, x2, y2
  end

  private

  def calculate_percentage_with_adjustment(frame, percentage, adjustment=10)
    # need to adjust for padding around control - using 10 pixels default
    x, y = frame['x'].to_f, frame['y'].to_f
    width, height = frame['width'].to_f, frame['height'].to_f
    adjustment = (percentage - 0.5) * (2*adjustment)
    if width < height
      x += width / 2
      y += height * percentage - adjustment
    else
      x += width * percentage - adjustment
      y += height / 2
    end
    return x, y
  end

  def trait(*traits)
    "(#{traits.map { |t| %Q{contains(@traits, "#{t}")} }.join(' or ')})"
  end

  def find_element(text, scope='')
    @xml.xpath(
      %Q{#{scope}//*[contains(., "#{text}") or contains(@label, "#{text}") or contains(@value, "#{text}") and frame]}
    )
  end
end
