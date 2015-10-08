require "rubygems"

require "simplecov"
require "coveralls"
SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
    SimpleCov::Formatter::HTMLFormatter,
    Coveralls::SimpleCov::Formatter
]
SimpleCov.start do
  add_filter "/test/"
  add_filter "/gemfiles/vendor"
end

require "codeclimate-test-reporter"
CodeClimate::TestReporter.start

require "minitest/autorun"
require "minitest/reporters"
MiniTest::Reporters.use!

require "shoulda"
require "shoulda-context"
require "shoulda-matchers"
require "mocha/setup"

# Make the code to be tested easy to load.
$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "..", "lib"))

require 'active_support/testing/assertions'
include ActiveSupport::Testing::Assertions

require "benchmark"

require "redis_fixtures"
require "redis"
require "connection_pool"


# Add helper methods to use in the tests
$RedisConnectionSettings = {host: 'localhost', port: 6379, db: 2}

class TestResetHelper
  def self.reset_configuration
    RedisFixtures.instance_variable_set(:@configuration, RedisFixtures::Configuration.new)
    RedisFixtures.configure do |config|
      config.connection_settings = $RedisConnectionSettings
    end
  end

  def self.reset_fixtures_file_and_db
    reset_configuration
    RedisFixtures.with_redis_connection do |redis|
      redis.flushdb
      redis.set("string_key", "blah")
      RedisFixtures.save_fixtures
      redis.flushdb
      redis.set("delete_me", "aa")
    end
  end
end


# Prepare some test data, before tests run, since we're testing a "before_setup" hook
TestResetHelper.reset_configuration
TestResetHelper.reset_fixtures_file_and_db

