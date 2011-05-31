require 'rake'

require 'rubygems'
require 'bundler'
Bundler.setup

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |t|
    t.libs << 'test'
    t.test_files = FileList['test/**/*_test.rb']
    t.verbose = true
  end
rescue LoadError
  puts "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
end

desc 'Run specs'
task :spec do
  system "rspec spec/sluggable_finder_spec.rb"
end

load File.join(File.dirname(__FILE__), 'tasks', 'db.rake')

task :default => :spec
