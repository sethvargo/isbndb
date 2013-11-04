require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

task :setup do
  FileUtils.cp('config/isbndb.example.yml', 'config/isbndb.yml')
end

task default: [:setup, :spec]
