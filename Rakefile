#!/usr/bin/env rake
require 'bundler/gem_tasks'
require 'rake/testtask'

# Compile
require 'rake/extensiontask'
Rake::ExtensionTask.new('bitwise_ext') do |ext|
  ext.ext_dir = 'ext'
end

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList['test/**/*_test.rb']
end

# Rake::Task[:test].prerequisites << :compile

task :default => :test
