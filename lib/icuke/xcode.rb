require 'appscript'
require 'timeout'

module ICuke
  class XCode
    def self.app
      @app ||= Appscript.app('Xcode.app')
    end

    def self.open_project(project_file)
      unless open_project?(project_file)
        app.launch
        app.open project_file
      end
      app.active_project_document.project
    end

    def self.open_project?(project_file)
      running? and
        app.active_project_document.get and
        app.active_project_document.project.path.get == project_file
    end

    def self.interface
      Appscript.app('System Events').application_processes['Xcode']
    end

    def self.running?
      app.is_running?
    end

    def self.quit
      IPhoneSimulator.quit
      app.quit if running?
      sleep(0.2) until !running?
    end

    def self.status
      interface.windows[1].static_texts[0].value.get
    end

    def self.launched_app?
      status =~ /launched$/
    end

    def self.installing_app?
      status =~ /^Installing/
    end

    def self.with_settings(project, settings, &block)
      initial_settings = {}

      settings.each_key { |setting| initial_settings[setting] = project.send(setting).get }
      settings.each_pair do |setting, value|
        project.send(setting).set value
      end

      yield
    ensure
      initial_settings.each_pair do |setting, value|
        project.send(setting).set value
      end if running?
    end
  end
  
  class IPhoneSimulator
    def self.app
      @app ||= Appscript.app('iPhone Simulator.app')
    end
    
    def self.quit
      app.quit if running?
      sleep(0.2) until !running?
    end
    
    def self.running?
      app.is_running?
    end
  end
  
  class Simulator
    include Timeout
    
    def launch(project_file, options = {})
      options = {
        :target => nil,
        :configuration => 'Debug'
      }.merge(options)
      
      # If we don't kill the simulator first the rest of this function becomes
      # a no-op and we don't land on the applications first page
      IPhoneSimulator.quit
      
      begin
        project = XCode.open_project(project_file)
        
        settings = {
          :active_build_configuration_type => project.build_configuration_types[options[:configuration]]
        }
        if options[:target]
          settings[:active_target] = project.targets[options[:target]]
        end
        
        XCode.with_settings(project, settings) do
          executable = project.active_executable.get
          options[:env].each_pair do |name, value|
            executable.make :new => :environment_variable,
                            :with_properties => { :name => name, :value => value, :active => true }
          end
          
          project.launch_
          
          sleep(0.5) while XCode.installing_app?
          
          unless XCode.launched_app?
            XCode.quit
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
      end
    end
    
    def quit
      IPhoneSimulator.quit
    end
  end
end
