require_relative "test_helper"

class ConnectionTest < MiniTest::Test
  context "with resetting of configuration" do
    setup do
      TestResetHelper.reset_configuration
    end

    teardown do
      TestResetHelper.reset_configuration
    end

    should "connect using a connection pool" do
      redis_pool = ::ConnectionPool.new(size: 2, timeout: 2) do
        Redis.new($RedisConnectionSettings)
      end

      RedisFixtures.configure do |config|
        config.connection_pool = redis_pool
        config.connection_settings = {host: 'localhost', port: 1111} # Just to make sure it's not using this
      end

      test_connection
    end

    should "connect using a connection proc" do
      RedisFixtures.configure do |config|
        config.connection_proc = Proc.new{ Redis.new($RedisConnectionSettings) }
        config.connection_settings = {host: 'localhost', port: 1111} # Just to make sure it's not using this
      end

      test_connection
    end

    should "connect using an existing connection" do
      conn = Redis.new($RedisConnectionSettings)

      RedisFixtures.configure do |config|
        config.connection = conn
        config.connection_settings = {host: 'localhost', port: 1111} # Just to make sure it's not using this
      end

      test_connection
    end

    should "connect using default connection settings" do
      RedisFixtures.configure do |config|
        config.connection_settings = {host: 'localhost', port: 6379} # Just to make sure it's not using this
      end

      test_connection
    end
  end

  private

  def test_connection
    RedisFixtures.with_redis_connection do |redis|
      redis.set "aaa", "bbb"
      assert_equal "bbb", redis.get("aaa")
    end
  end
end
