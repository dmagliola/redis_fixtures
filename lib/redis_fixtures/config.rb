module RedisFixtures
  # Thrown when a config setting is invalid
  class InvalidConfigSettingError < StandardError; end

  # Holds the configuration
  class Configuration
    # Root directory of the app (where the test or spec directory exists)
    # Defaults to Rails.root, use only if using this gem in a non-Rails environment
    attr_accessor :app_root

    # Filename where to store the Redis fixtures. (Will be stored in regular fixtures path)
    # Defaults to redis.yml
    attr_accessor :fixture_filename

    # Connection Pool used to get a new Redis connection
    # One of :connection_pool, :connection_block, :connection_settings or :connection must be set
    attr_accessor :connection_pool

    # Connection Proc that yields a connection object when needed
    # One of :connection_pool, :connection_block, :connection_settings or :connection must be set
    attr_accessor :connection_proc

    # Connection to Redis for the library to use
    # One of :connection_pool, :connection_block, :connection_settings or :connection must be set
    attr_accessor :connection_settings

    # Connection to Redis for the library to use
    # One of :connection_pool, :connection_block, :connection_settings or :connection must be set
    attr_accessor :connection

    def initialize
      @connection_settings = {host: 'localhost', port: 6379}
      @fixture_filename = "redis.fixture"
      @app_root = defined?(::Rails) ? ::Rails.root : Dir.pwd
    end
  end

  # Returns the current configuration
  def self.configuration
    @configuration ||=  Configuration.new
  end

  # Yields the current configuration, allowing the caller to modify it in a block
  def self.configure
    yield(configuration) if block_given?
  end

  def self.fixture_file_path
    fixtures_dir(RedisFixtures.configuration.fixture_filename)
  end

  private

  def self.fixtures_dir(path = '')
    File.expand_path(File.join(RedisFixtures.configuration.app_root, spec_or_test_dir, 'fixtures', path))
  end

  def self.spec_or_test_dir
    File.exists?(File.join(RedisFixtures.configuration.app_root, 'spec')) ? 'spec' : 'test'
  end
end
