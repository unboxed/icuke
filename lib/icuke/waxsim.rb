require 'background_process'
require 'tmpdir'

module ICuke
  class Simulator
    include Timeout
    
    attr_accessor :current_process
    
    def launch(process)
      project_file = process.project_file
      options = process.launch_options
      
      options = {
        :configuration => 'Debug',
        :env => {}
      }.merge(options)
      
      app_name = File.basename(project_file, '.xcodeproj')
      directory = "#{File.dirname(project_file)}/build/#{options[:configuration]}-iphonesimulator"
      
      options[:env]['CFFIXED_USER_HOME'] = Dir.mktmpdir
      
      command = ICuke::SDK.launch("#{directory}/#{app_name}.app", options[:platform], options[:env])
      @simulator = BackgroundProcess.run(command)
      
      self.current_process = process

      timeout(30) do
        begin
          view
        rescue Errno::ECONNREFUSED, Errno::ECONNRESET, EOFError
          sleep(0.5)
          retry
        end
      end
    end
    
    def quit
      get '/quit' rescue nil # results in a hard exit(0)
      @simulator.wait
      self.current_process = nil
    end
    
    def suspend
      @simulator.kill('QUIT') # invokes the normal app exit routine
      @simulator.wait
      sleep 1
    end
    
    def resume
      launch(self.current_process)
    end
    
    class Process
      attr_reader :project_file, :launch_options
      def initialize(project_file, launch_options = {})
        @project_file = project_file
        @launch_options = launch_options
      end
    end
  end
end
