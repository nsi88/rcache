module ActiveRecord
  module QueryMethods
    attr_accessor :rcache_value

    def rcache(opts = {})
      relation = clone
      relation.rcache_value = opts
      relation
    end

    alias :super_build_arel :build_arel

    def build_arel
      if @rcache_value
        old = connection.redis_query_cache_enabled
        connection.enable_redis_query_cache!(@rcache_value)
      end
      begin
        res = super_build_arel
      ensure
        connection.disable_redis_query_cache! if @rcache_value && !old
      end
      res
    end
  end
end
