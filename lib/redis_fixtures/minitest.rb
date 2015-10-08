module MinitestRedisFixtures
  def before_setup
    super
    RedisFixtures.load_fixtures
  end
end

class MiniTest::Test
  include MinitestRedisFixtures
end
