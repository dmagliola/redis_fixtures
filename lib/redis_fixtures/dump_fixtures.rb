module RedisFixtures
  # Cleans up the Redis DB. Call this before starting your sample data generation
  # to start with a clean slate
  def self.before_fixture_data_generation
    with_redis_connection do |redis|
      redis.flushdb
    end
  end

  # Dumps the contents of the Redis DB into a fixture file.
  # Call this after generating all your sample data in Redis.
  def self.save_fixtures
    redis_dump = with_redis_connection do |redis|
      dump_keys(redis)
    end
    FileUtils.mkdir_p(fixtures_dir) unless File.directory?(fixtures_dir)
    File.open(fixture_file_path, 'w') { |file| file.write(redis_dump.to_yaml) }
  end

  private

  # Finds all the keys in the Redis Database and dumps them into an array of arrays
  # that can then be used to easily reconstruct the data
  #
  # @param redis [Redis] Redis connection
  # @return [Array of `commands`] an array of arrays, one entry per key, each of which
  # can be used to execute a redis call that will create and populate the key in Redis.
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

  # Dump a Redis Hash into a `command` that will allows us to regenerate it
  # @param redis [Redis] Redis connection
  # @param key [String] the key to dump
  # @return [Array] an array specifying a `mapped_hmset` command, the key, and the hash to store in Redis
  def self.dump_hash(redis, key)
    hash = redis.hgetall(key)
    [:mapped_hmset, key, hash]
  end

  # Dump a Redis Sorted Set into a `command` that will allows us to regenerate it
  # @param redis [Redis] Redis connection
  # @param key [String] the key to dump
  # @return [Array] an array specifying a `zadd` command, the key, and the values and scores to store in Redis
  def self.dump_zset(redis, key)
    zset = redis.zrange key, 0, -1, with_scores: true
    zset = zset.map{|entry| entry.reverse} # Zrange returns [["a", 32.0], ["b", 64.0]]. Zadd wants [[32.0, "a"], [64.0, "b"]]
    [:zadd, key, zset]
  end

  # Dump a Redis List into a `command` that will allows us to regenerate it
  # @param redis [Redis] Redis connection
  # @param key [String] the key to dump
  # @return [Array] an array specifying a `rpush` command, the key, and the values and scores to store in Redis
  def self.dump_list(redis, key)
    list = redis.lrange key, 0, -1
    [:rpush, key, list]
  end

  # Dump a Redis Set into a `command` that will allows us to regenerate it
  # @param redis [Redis] Redis connection
  # @param key [String] the key to dump
  # @return [Array] an array specifying a `sadd` command, the key, and the values and scores to store in Redis
  def self.dump_set(redis, key)
    set = redis.smembers key
    [:sadd, key, set]
  end

  # Dump a Redis String into a `command` that will allows us to regenerate it
  # This also covers HyperLogLogs and Bitmaps.
  # @param redis [Redis] Redis connection
  # @param key [String] the key to dump
  # @return [Array] an array specifying a `set` command, the key, and the string to store in Redis
  def self.dump_string(redis, key)
    [:set, key, redis.get(key)]
  end
end
