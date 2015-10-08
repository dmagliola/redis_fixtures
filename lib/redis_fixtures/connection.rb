module RedisFixtures
  def self.with_redis_connection
    result = nil
    conf = RedisFixtures.configuration
    if conf.connection_pool.present?
      conf.connection_pool.with do |redis|
        result = yield(redis)
      end
    elsif conf.connection.present?
      result = yield(conf.connection)
    elsif conf.connection_proc.present? || conf.connection_settings.present?
      redis = conf.connection_proc.present? ?
                conf.connection_proc.call :
                Redis.new(conf.connection_settings)
      result = yield(redis)
      redis.disconnect!
    end
    result
  end
end
