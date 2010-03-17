require 'osx/cocoa'
OSX.require_framework '/Developer/Platforms/iPhoneSimulator.platform/Developer/Library/PrivateFrameworks/iPhoneSimulatorRemoteClient.framework'
require 'httparty'

module ICuke
  class Simulator < OSX::NSObject
    include OSX
    include HTTParty
    base_uri 'http://localhost:50000'
    
    class FailedToStart < RuntimeError; end
    
    objc_method :session_didStart_withError, 'v@:@i@'
    def session_didStart_withError(session, started, error)
      unless started == 1
        raise FailedToStart, error
      end
      CFRunLoopStop(CFRunLoopGetCurrent())
    end
    
    objc_method :session_didEndWithError, 'v@:@@'
    def session_didEndWithError(session, error)
      raise FailedToStart, error if error
    end
    
    def launch(application, options = {})
      options = {
        :sdk => nil,
        :client_name => 'Cucumber',
        :args => [],
        :env => { },
        :debugger => false
      }.merge!(options)
      
      spec = OSX::DTiPhoneSimulatorApplicationSpecifier.specifierWithApplicationPath application
      
      sdk_root = begin
        if options[:sdk]
          OSX::DTiPhoneSimulatorSystemRoot.knownRoots.find do |root|
            root.sdkVersion == options[:sdk]
          end
        else
          OSX::DTiPhoneSimulatorSystemRoot.defaultRoot
        end
      end
      
      config = OSX::DTiPhoneSimulatorSessionConfig.alloc.init
      config.setApplicationToSimulateOnStart spec
      config.setSimulatedSystemRoot sdk_root
      config.setSimulatedApplicationShouldWaitForDebugger options[:debugger]
      config.setSimulatedApplicationLaunchArgs options[:args]
      config.setSimulatedApplicationLaunchEnvironment options[:env]
      config.setLocalizedClientName options[:client_name]
      
      session = OSX::DTiPhoneSimulatorSession.alloc.init
      session.setDelegate self
      session.setSimulatedApplicationPID OSX::NSNumber.numberWithInt 35
      result, error = session.requestStartWithConfig_timeout_error config, 30
      
      if !result
        raise FailedToStart, error
      end
      
      # Spin until we get a callback indicating success/failure
      OSX::CFRunLoopRun()
    end
    
    def quit
      get '/quit'
    rescue EOFError
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
      get '/save', :query => { :file => path }
    end
    
    def load(path)
      get '/load', :query => { :file => path }
    end
    
    def play
      get '/play'
    end
    
    def fire_event(event)
      get '/event', :query => { :json => event.to_json }
    end
    
    def set_defaults(defaults)
      get '/defaults', :query => { :json => defaults.to_json }
    end
    
    private
    
    def get(path, options = {})
      self.class.get(path, options).body
    end
  end
end
