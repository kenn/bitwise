#!/usr/bin/env rake
require 'bundler/gem_tasks'

# Compile
require 'rake/extensiontask'
Rake::ExtensionTask.new('bitwise_ext') do |ext|
  ext.ext_dir = 'ext'
end

# RSpec
require 'rspec/core/rake_task'
task :default => :spec
RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = ["--color"]
  t.fail_on_error = false
end
Rake::Task[:spec].prerequisites << :compile
