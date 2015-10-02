lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "redis_fixtures/version"

Gem::Specification.new do |s|
  s.name        = 'redis_fixtures'
  s.version     = RedisFixtures::VERSION
  s.summary     = "Add fixtures to your Redis database, to test the parts of your code that need Redis to be more than a cache."
  s.description = %q{RedisFixtures allows you to have fixtures for Redis, in addition to the ones for your database.
                       If you are using Redis as more than just a cache (and I hope you are), you probably need to have
                       some data there to test your application. RedisFixtures will reset your (test) Redis database
                       at the beginning of every test to the fixture you set.
                       And if you use FixtureBuilder (or any other fixture-generating library), you can automatically
                       generate your Redis fixture from the contents of your test Redis database.
                   }
  s.authors     = ["Daniel Magliola"]
  s.email       = 'dmagliola@crystalgears.com'
  s.homepage    = 'https://github.com/dmagliola/redis_fixtures'
  s.license     = 'MIT'

  s.files       = `git ls-files`.split($/)
  s.executables   = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.test_files    = s.files.grep(%r{^(test|s.features)/})
  s.require_paths = ["lib"]

  s.required_ruby_version = ">= 1.9.3"

  s.add_runtime_dependency "redis", '>= 3.0'

  s.add_development_dependency "bundler"
  s.add_development_dependency "rake"

  s.add_development_dependency "minitest"
  s.add_development_dependency "minitest-reporters"
  s.add_development_dependency "shoulda"
  s.add_development_dependency "mocha"
  s.add_development_dependency "simplecov"

  s.add_development_dependency "appraisal"
  s.add_development_dependency "coveralls"
  s.add_development_dependency "codeclimate-test-reporter"
end
