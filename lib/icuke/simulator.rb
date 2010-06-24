require 'icuke/core_ext'
require 'icuke/waxsim'

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
      get '/save', :query => path
    end
    
    def load(path)
      get '/load', :query => path
    end
    
    def play
      get '/play'
    end
    
    def load_module(path)
      get '/module', :query => path
    end
    
    def fire_event(event)
      get '/event', :query => event.to_json
    end
    
    def set_defaults(defaults)
      get '/defaults', :query => defaults.to_json
    end
    
    def get(path, options = {})
      options[:query] = URI.escape(options[:query]) if options.has_key?(:query)
      response = self.class.get(path, options)
      if response.code != 200
        raise Simulator::Error, response.body
      end
      response.body
    end
  end
end
