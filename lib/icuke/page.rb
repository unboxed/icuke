require 'nokogiri'

class Page
  attr_reader :xml
  
  def initialize(root)
    @xml = Nokogiri::XML::Document.parse(root).root
  end
  
  def exists?(text, scope = '')
    find_element(text, scope).any?
  end

  def onscreen?(text, scope='')
    element = find_element(text, scope).first
    x, y = element_position(element)
    return x >= 0 && y >= 0 && x < 320 && y < 480
  end

  def element_position(element)
    # This seems brittle, revist how to fetch the frame without relying on it being the only child
    frame = element.child
    
    x = frame['x'].to_f
    y = frame['y'].to_f
    
    # Hit the element in the middle
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
    raise %Q{No element labelled "#{label}" found in: #@xml} unless element
    element
  end


  def first_slider_element(label)
    element =
      @xml.xpath(
                 %Q{//UISlider[@label="#{label}" and frame]},
                 %Q{//*[@label="#{label}"]/../UISlider}         
                 ).first
    raise %Q{No element labelled "#{label}" found in: #@xml} unless element
    element
    
  end

  def find_slider_button(element)
    frame = element.child
    x, y = frame['x'].to_f, frame['y'].to_f
    width, height = frame['width'].to_f, frame['height'].to_f
    percentage = 0.01 * element['value'].to_f
    # need to adjust for padding around control - using 10 pixels max
    adjustment = (percentage - 0.5) * 20
    if width < height
      x += width / 2
      y += height * percentage - adjustment
    else
      x += width * percentage - adjustment
      y += height / 2
    end
    return x, y
  end

  
  private
  
  def trait(*traits)
    "(#{traits.map { |t| %Q{contains(@traits, "#{t}")} }.join(' or ')})"
  end

  def find_element(text, scope='')
    @xml.xpath(
               %Q{#{scope}//*[contains(., "#{text}") or contains(@label, "#{text}") or contains(@value, "#{text}") and frame]}
               )
  end

end
