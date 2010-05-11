require 'icuke/core_ext'
if ENV['ICUKE_HEADLESS']
  require 'icuke/headless'
else
  require 'icuke/xcode'
end

require 'httparty'

module ICuke
  class Simulator
    include Timeout
    include HTTParty
    base_uri 'http://localhost:50000'
    
    class Error < StandardError; end
    
    def view
      get('/view')
    end
    
    def record
      get '/record'
    end
    
    def stop
      get '/stop'
    end
    
    def save(path)
      get '/save', :query => URI.escape(path)
    end
    
    def load(path)
      get '/load', :query => URI.escape(path)
    end
    
    def play
      get '/play'
    end
    
    def fire_event(event)
      get '/event', :query => URI.escape(event.to_json)
    end
    
    def set_defaults(defaults)
      get '/defaults', :query => URI.escape(defaults.to_json)
    end
    
    private
    
    def get(path, options = {})
      response = self.class.get(path, options)
      if response.code != 200
        raise Simulator::Error, response.body
      end
      response.body
    end
  end
end
