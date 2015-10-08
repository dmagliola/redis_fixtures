# Module to set a before_setup Minitest hook, to reset Redis to the state specified by the fixture
# before each test runs
module MinitestRedisFixtures
  def before_setup
    super
    RedisFixtures.load_fixtures
  end
end

class MiniTest::Test
  include MinitestRedisFixtures
end
