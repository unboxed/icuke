require 'rubygems'
require 'rake'
require 'lib/icuke/sdk'

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
    gem.add_dependency "httparty", ">= 0"
    gem.add_dependency "nokogiri", ">= 0"
    gem.add_dependency "background_process"
    gem.extensions = ['ext/Rakefile']
    gem.files += ['ext/bin/waxsim']
    gem.files += ['ext/iCuke/libicuke*.dylib']
    gem.files += ['ext/WaxSim/**/*']
    gem.files -= ['ext/WaxSim/build']
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

file 'app/build/Debug-iphonesimulator/Universal.app/Universal' do
  ICuke::SDK.use_latest
  sh "cd app && xcodebuild -target Universal -configuration Debug -sdk #{ICuke::SDK.fullname}"
end
task :app => 'app/build/Debug-iphonesimulator/Universal.app/Universal'
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
