require 'tmpdir'

module ICuke
  class Simulator
    include Timeout
    
    def launch(project_file, options = {})
      options = {
        :configuration => 'Debug',
        :env => {}
      }.merge(options)
      
      app_name = File.basename(project_file, '.xcodeproj')
      directory = "#{File.dirname(project_file)}/build/#{options[:configuration]}-iphonesimulator"
      
      ENV['DYLD_FRAMEWORK_PATH'] = directory
      ENV['DYLD_ROOT_PATH'] = ICuke::SDK.root
      ENV['IPHONE_SIMULATOR_ROOT'] = ICuke::SDK.root
      ENV['CFFIXED_USER_HOME'] = Dir.mktmpdir
      ENV['ICUKE_KEEP_PREFERENCES'] = '1'
      
      options[:env].each_pair do |k, v|
        ENV[k] = v
      end
      
      command = "#{directory}/#{app_name}.app/#{app_name} -RegisterForSystemEvents"
      @pid = fork {
        STDIN.close
        STDERR.close
        STDOUT.close
        
        exec(command)
      }
      
      timeout(30) do
        begin
          view
        rescue Errno::ECONNREFUSED
          sleep(0.5)
          retry
        end
      end
    end
    
    def quit
      Process.kill('TERM', @pid)
      Process.wait(@pid)
    end
  end
end
