require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "iCuke"
    gem.summary = %Q{Cucumber support for iPhone applications}
    gem.description = %Q{Cucumber support for iPhone applications}
    gem.email = "rob@the-it-refinery.co.uk"
    gem.homepage = "http://github.com/unboxed/iCuke"
    gem.authors = ["Rob Holland"]
    gem.add_dependency "cucumber", ">= 0"
    gem.add_dependency "rb-appscript", ">= 0"
    gem.add_dependency "httparty", ">= 0"
    gem.extensions = ['ext/iCuke/Rakefile']
    gem.files += ['ext/iCuke/libicuke.dylib']
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

file 'app/iCuke/build/Debug-iphonesimulator/iCuke.app/iCuke' do
  sh 'cd app/iCuke && xcodebuild -target iCuke -configuration Debug -sdk iphonesimulator3.1.2'
end
task :app => 'app/iCuke/build/Debug-iphonesimulator/iCuke.app/iCuke'
task :features => :app

task :lib do
  sh 'cd ext/iCuke && rake'
end

begin
  require 'cucumber/rake/task'
  Cucumber::Rake::Task.new(:features)

  task :features => :check_dependencies
  task :features => [:app, :lib]
rescue LoadError
  task :features do
    abort "Cucumber is not available. In order to run features, you must: sudo gem install cucumber"
  end
end

task :default => :features

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "iCuke #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

task :launch => [:app, :lib] do
  require 'lib/icuke/simulator'

  simulator = ICuke::Simulator.new
  simulator.launch File.expand_path('app/iCuke/build/Debug-iphonesimulator/iCuke.app'),
    :env => { 'DYLD_INSERT_LIBRARIES' => File.expand_path(File.dirname(__FILE__) + '/ext/iCuke/libicuke.dylib') }
end

task :replay => :launch do
  simulator = ICuke::Simulator.new
  simulator.load(File.expand_path(File.dirname(__FILE__) + '/events.plist'))
  simulator.play
end

task :debug => [:app, :lib] do
  require 'lib/icuke/simulator'

  simulator = ICuke::Simulator.new
  simulator.launch File.expand_path('app/iCuke/build/Debug-iphonesimulator/iCuke.app'),
    :env => { 'DYLD_INSERT_LIBRARIES' => File.expand_path(File.dirname(__FILE__) + '/ext/iCuke/libicuke.dylib') },
    :debugger => true
  puts `ps aux|grep [i]Cuke.app/iCuke`
end
