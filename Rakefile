# require "bundler/gem_tasks"
# require 'rubygems'
# require 'bundler'

require "rake/extensiontask"
Rake::ExtensionTask.new("bitwise")

require 'rspec/core/rake_task'
task :default => :spec
RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = ["--color"]
  t.fail_on_error = false
end
Rake::Task[:spec].prerequisites << :compile

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "bitwise"
  gem.homepage = "http://github.com/kenn/bitwise"
  gem.license = "MIT"
  gem.summary = %Q{Fast, memory efficient bitwise operations on large binary strings}
  gem.description = %Q{Fast, memory efficient bitwise operations on large binary strings}
  gem.email = "kenn.ejima@gmail.com"
  gem.authors = ["Kenn Ejima"]
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new
