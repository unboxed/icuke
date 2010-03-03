require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "iCuke"
    gem.summary = %Q{Cucumber support for iPhone applications}
    gem.description = %Q{Cucumber support for iPhone applications}
    gem.email = "rob@the-it-refinery.co.uk"
    gem.homepage = "http://github.com/robholland/iCuke"
    gem.authors = ["Rob Holland"]
    gem.add_development_dependency "cucumber", ">= 0"
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
task :features => 'app/iCuke/build/Debug-iphonesimulator/iCuke.app/iCuke'

begin
  require 'cucumber/rake/task'
  Cucumber::Rake::Task.new(:features)

  task :features => :check_dependencies
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
