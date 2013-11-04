# encoding: utf-8
$:.push File.expand_path('../lib', __FILE__)

Gem::Specification.new do |s|
  s.name        = 'isbndb'
  s.version     = '2.0.1'
  s.author      = 'Seth Vargo'
  s.email       = 'sethvargo@gmail.com'
  s.homepage    = 'https://github.com/sethvargo/isbndb'
  s.summary     = 'Connect with ISBNdb.com\'s API'
  s.description = 'Ruby ISBNdb is a amazingly fast and accurate gem that reads ISBNdb.com\'s XML API and gives you incredible flexibilty with the results! The newest version of the gem also features caching, so developers minimize API-key usage.'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # Runtime dependencies
  s.add_runtime_dependency 'httparty',    '~> 0.12'
  s.add_runtime_dependency 'rake'

  # Development dependencies
  s.add_development_dependency 'rspec',   '~> 2.14'
  s.add_development_dependency 'webmock', '~> 1.15'
end
