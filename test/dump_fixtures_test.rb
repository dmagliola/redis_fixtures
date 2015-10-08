require_relative "test_helper"

class DumpFixturesTest < MiniTest::Test
  should "dump fixtures" do
    begin
      # Check that we start with the normal keys
      RedisFixtures.with_redis_connection do |redis|
        assert_equal ["string_key"], redis.keys("*")
      end

      # Set some new data in Redis
      commands = [
        [:mapped_hmset, "hash1", {"a" => "1", "b" => "2", "c" => "3"}],
        [:zadd, "zset1", [[32.0, "a"], [64.0, "b"]]],
        [:rpush, "list1", ["3", "4", "5", "6"]],
        [:sadd, "set1", ["3", "4", "5", "6"]],
        [:set, "string1", "thestring!"],
      ]
      keys = commands.map{|cmd| cmd[1]}

      RedisFixtures.with_redis_connection do |redis|
        redis.flushdb
        commands.each do |cmd|
          redis.send(*cmd)
        end

        # Check that the keys are there
        assert_equal keys.sort, redis.keys("*").sort
      end

      RedisFixtures.save_fixtures

      # Check the YAML file
      serialized_commands = YAML.load_file(RedisFixtures.fixture_file_path)
      assert_equal commands.sort_by{|cmd| cmd[1]}, serialized_commands.sort_by{|cmd| cmd[1]}
    rescue
    ensure
      TestResetHelper.reset_fixtures_file_and_db
    end
  end

  should "clear DB before fixture generation" do
    RedisFixtures.before_fixture_data_generation
    RedisFixtures.with_redis_connection do |redis|
      assert_equal [], redis.keys("*")
    end
  end

  should "raise an exception if it finds a strange key type in Redis" do
    # This can't actually happen, but it's future proofing. Thus, we need to mock.
    Redis.any_instance.expects(:type).returns("unknown_type")
    assert_raises RuntimeError do
      RedisFixtures.save_fixtures
    end
  end
end
