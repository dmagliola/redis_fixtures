module RedisFixtures
  # Load the Redis fixture YAML file, into Redis, flushing the DB first
  def self.load_fixtures
    return unless File.exists?(fixture_file_path)
    commands = YAML.load_file(fixture_file_path)
    with_redis_connection do |redis|
      redis.pipelined do |predis|
        predis.flushdb
        commands.each do |command|
          predis.send(*command)
        end
      end
    end
  end
end
