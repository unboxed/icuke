require 'background_process'
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
      
      options[:env]['CFFIXED_USER_HOME'] = Dir.mktmpdir
      
      command = ICuke::SDK.launch("#{directory}/#{app_name}.app", options[:platform], options[:env])
      @simulator = BackgroundProcess.run(command)

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
      get '/quit' rescue nil
      @simulator.wait
    end
  end
end
