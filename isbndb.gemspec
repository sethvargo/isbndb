# encoding: utf-8
$:.push File.expand_path('../lib', __FILE__)

Gem::Specification.new do |s|
  s.name        = 'isbndb'
  s.version     = '3.0.0'
  s.author      = 'Seth Vargo'
  s.email       = 'sethvargo@gmail.com'
  s.homepage    = 'https://github.com/sethvargo/isbndb'
  s.summary     = 'Connect with ISBNdb.com\'s API'
  s.description = 'Ruby ISBNdb is a amazingly fast and accurate gem that reads ISBNdb.com\'s XML API and gives you incredible flexibility with the results! The newest version of the gem also features caching, so developers minimize API-key usage.'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency 'rspec', '~> 2.12.0'
  s.add_development_dependency 'shoulda', '~> 3.3.2'
  s.add_development_dependency 'simplecov', '~> 0.7.1'
  s.add_development_dependency 'webmock', '~> 1.9.0'
  s.add_development_dependency 'yard', '~> 0.8.3'

  s.add_runtime_dependency 'activesupport'
  s.add_runtime_dependency 'httparty', '~> 0.9.0'
  # s.add_runtime_dependency 'httparty-icebox', '~> 0.0.4'
  s.add_runtime_dependency 'rake', '>= 10.0.3'
end
