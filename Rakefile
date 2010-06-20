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
    gem.extensions = ['ext/Rakefile']
    gem.files += ['bin/iphonesim']
    gem.files += ['ext/iCuke/libicuke*.dylib']
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

file 'app/build/Debug-iphonesimulator/Universal.app/Universal' do
  sh "cd app && xcodebuild -target Universal -configuration Debug -sdk #{ICuke::SDK.fullname}"
end
task :app => 'app/sdk3/build/Debug-iphonesimulator/UICatalog.app/UICatalog'
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
