require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

namespace :test do
  desc 'Run tests against the CI'
  task :ci => [:spec]
end
