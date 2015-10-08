require_relative "test_helper"

class LoadFixturesTest < MiniTest::Test
  should "load fixtures" do
    begin
      # Generate a new fixtures file
      commands = [
        [:zadd, "zset1", [[32.0, "a"], [64.0, "b"]]],
        [:rpush, "list1", ["3", "4", "5", "6"]],
        [:set, "string1", "thestring!"],
      ]
      File.open(RedisFixtures.fixture_file_path, 'w') { |file| file.write(commands.to_yaml) }

      # Check that we start with the normal keys
      RedisFixtures.with_redis_connection do |redis|
        assert_equal ["string_key"], redis.keys("*")
      end

      RedisFixtures.load_fixtures

      # Check that we have these new keys in the DB
      RedisFixtures.with_redis_connection do |redis|
        assert_equal ["zset1", "list1", "string1"].sort, redis.keys("*").sort
        assert_equal ["3", "4", "5", "6"], redis.lrange("list1", 0, -1)
        assert_equal ["a", "b"], redis.zrange("zset1", 0, -1)
      end
    rescue
    ensure
      TestResetHelper.reset_fixtures_file_and_db
    end
  end
end
