require 'simplecov'
SimpleCov.start

require 'rspec'
require 'shoulda'
# require 'webmoc/k/rspec'

Dir[File.expand_path('spec/support/**/*.rb')].each { |f| require f }

require 'isbndb'

RSpec.configure do |config|
  config.include Helpers
end
