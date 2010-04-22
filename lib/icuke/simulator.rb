require 'icuke/core_ext'

require 'httparty'
require 'appscript'
require 'timeout'

module ICuke
  class Simulator
    include Timeout
    include HTTParty
    base_uri 'http://localhost:50000'
    
    class Error < StandardError; end
    
    def launch(project_file, options = {})
      options = {
        :target => nil,
        :configuration => 'Debug'
      }.merge(options)
      
      # If we don't kill the simulator first the rest of this function becomes
      # a no-op and we don't land on the applications first page
      simulator = Appscript.app('iPhone Simulator.app')
      simulator.quit if simulator.is_running?
      
      begin
        project = open_project(project_file)
        
        settings = {
          :active_build_configuration_type => project.build_configuration_types[options[:configuration]]
        }
        if options[:target]
          settings[:active_target] = project.targets[options[:target]]
        end
        
        with_settings(project, settings) do
          executable = project.active_executable.get
          options[:env].each_pair do |name, value|
            executable.make :new => :environment_variable,
                            :with_properties => { :name => name, :value => value, :active => true }
          end
          
          project.launch_
          
          timeout(30) do
            sleep(0.5) until simulator.is_running?
          end
        end
      rescue Timeout::Error
        xcode = Appscript.app('Xcode.app')
        xcode.quit if xcode.is_running?
        sleep(0.5) until !xcode.is_running?
        retry
      end
      
      timeout(30) do
        begin
          view
        rescue Errno::ECONNREFUSED
          sleep(0.5)
          retry
        end
      end
    end
    
    def open_project(project_file)
      xcode = Appscript.app('Xcode.app')
      unless xcode.active_project_document.get and xcode.active_project_document.project.path.get == project_file
        xcode.launch
        xcode.open project_file
      end
      xcode.active_project_document.project
    end
    
    def with_settings(project, settings, &block)
      initial_settings = {}
      
      settings.each_key { |setting| initial_settings[setting] = project.send(setting).get }
      settings.each_pair do |setting, value|
        project.send(setting).set value
      end
      
      yield
    ensure
      initial_settings.each_pair do |setting, value|
        project.send(setting).set value
      end
    end
    
    def quit
      Appscript.app('iPhone Simulator.app').quit
    end
    
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
