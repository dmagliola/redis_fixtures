require_relative "test_helper"

class MinitestHookTest < MiniTest::Test
  should "have cleaned the database and loaded the fixtures" do
    # Test helper left the DB with one key called "delete_me", and the fixture says there's one string called "string_key"
    # When the test runs, the DB should reflect the fixture
    RedisFixtures.with_redis_connection do |redis|
      keys = redis.keys("*")
      assert_equal ["string_key"], keys
    end
  end
end
