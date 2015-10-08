module RedisFixtures
  def self.before_fixture_data_generation
    with_redis_connection do |redis|
      redis.flushdb
    end
  end

  def self.save_fixtures
    redis_dump = with_redis_connection do |redis|
      dump_keys(redis)
    end
    FileUtils.mkdir_p(fixtures_dir) unless File.directory?(fixtures_dir)
    File.open(fixture_file_path, 'w') { |file| file.write(redis_dump.to_yaml) }
  end

  private

  def self.dump_keys(redis)
    keys = redis.keys("*")
    keys.map do |key|
      key_type = redis.type(key)
      case key_type
        when "hash"
          dump_hash(redis, key)
        when "zset"
          dump_zset(redis, key)
        when "list"
          dump_list(redis, key)
        when "set"
          dump_set(redis, key)
        when "string" # HLL's are stored internally as strings
          dump_string(redis, key)
        else
          raise "Don't know how to dump a fixture for Redis type: #{key_type} (key: #{key})" # Should never happen, these are all the types Redis can return
      end
    end
  end

  def self.dump_hash(redis, key)
    hash = redis.hgetall(key)
    [:mapped_hmset, key, hash]
  end

  def self.dump_zset(redis, key)
    zset = redis.zrange key, 0, -1, with_scores: true
    zset = zset.map{|entry| entry.reverse} # Zrange returns [["a", 32.0], ["b", 64.0]]. Zadd wants [[32.0, "a"], [64.0, "b"]]
    [:zadd, key, zset]
  end

  def self.dump_list(redis, key)
    list = redis.lrange key, 0, -1
    [:rpush, key, list]
  end

  def self.dump_set(redis, key)
    set = redis.smembers key
    [:sadd, key, set]
  end

  def self.dump_string(redis, key)
    [:set, key, redis.get(key)]
  end
end
