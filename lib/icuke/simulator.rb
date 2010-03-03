require 'osx/cocoa'
OSX.require_framework '/Developer/Platforms/iPhoneSimulator.platform/Developer/Library/PrivateFrameworks/iPhoneSimulatorRemoteClient.framework'

module ICuke
  class Simulator < OSX::NSObject
    include OSX
    
    class FailedToStart < RuntimeError; end
    
    objc_method :session_didStart_withError, 'v@:@i@'
    def session_didStart_withError(session, started, error)
      unless started == 1
        raise FailedToStart, error
      end
      CFRunLoopStop(CFRunLoopGetCurrent())
    end
    
    def launch(application, options = {})
      options = {
        :sdk => nil,
        :client_name => 'Cucumber',
        :args => [],
        :env => { }
      }.merge!(options)
      
      spec = OSX::DTiPhoneSimulatorApplicationSpecifier.specifierWithApplicationPath application
      
      sdk_root = begin
        if options[:sdk]
          OSX::DTiPhoneSimulatorSystemRoot.knownRoots.find do |root|
            root.sdkVersion == SDK_VERSION
          end
        else
          OSX::DTiPhoneSimulatorSystemRoot.defaultRoot
        end
      end
      
      config = OSX::DTiPhoneSimulatorSessionConfig.alloc.init
      config.setApplicationToSimulateOnStart spec
      config.setSimulatedSystemRoot sdk_root
      config.setSimulatedApplicationShouldWaitForDebugger false
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
  end
end