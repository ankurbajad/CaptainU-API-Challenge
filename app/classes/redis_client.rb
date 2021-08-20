
class RedisClient
  REDIS_URL = configatron.redis_host
  def initialize(simulation_id, section)
    @simulation_id = simulation_id
    @section = section
  end

  def get
    begin
      keys = get_keys
      get_values(keys.sort)
    rescue => exception
      raise  exception.to_s
    end
  end

  attr_reader :simulation_id, :section

  private

  def get_keys
    redis.keys("Simulation#{simulation_id}#{section}*")
  end

  def get_values(sorted_keys)
    sorted_keys.map{|key| redis.hget(key, "data") }
  end

  def redis
    Redis.new(:host=>REDIS_URL,:port=>6379)
  end
end