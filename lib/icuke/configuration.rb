module ICuke
  class Configuration
    def initialize(defaults = {})
      @data = defaults
    end
    
    def set(key, value)
      @data[key] = value
    end
    
    def get(key)
      @data[key]
    end
    
    def [](key)
      get(key)
    end
  end
end
