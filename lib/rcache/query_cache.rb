module ActiveRecord
  module ConnectionAdapters # :nodoc:
    module QueryCache
      attr_reader :redis_query_cache_enabled

      def enable_redis_query_cache!(options = {})
        @redis_query_cache_enabled = true
        @redis_query_cache_options = options
      end

      def disable_redis_query_cache!
        @redis_query_cache_enabled = false
      end

      def select_all(arel, name = nil, binds = [])
        if @redis_query_cache_enabled && !locked?(arel)
          sql = to_sql(arel, binds)
          redis_cache_sql(sql, binds) { super(sql, name, binds) }
        elsif @query_cache_enabled && !locked?(arel)
          sql = to_sql(arel, binds)
          cache_sql(sql, binds) { super(sql, name, binds) }
        else
          super
        end
      end

      private

      def redis_cache_sql(sql, binds)
        [:redis, :expires_in, :log_cached_queries].each do |attr|
          instance_variable_set("@#{attr}", @redis_query_cache_options.has_key?(attr) ? @redis_query_cache_options[attr] : Rcache.send(attr))
        end

        result =
          # return from memory
          if @query_cache[sql].key?(binds)
            ActiveSupport::Notifications.instrument("sql.active_record", :sql => sql, :binds => binds, :name => "CACHE", :connection_id => object_id) if @log_cached_queries
            @query_cache[sql][binds]
          # write to memory from redis and return
          elsif res = (JSON.parse(@redis.hget(sql, binds.to_s)) rescue nil)
            ActiveSupport::Notifications.instrument("sql.active_record", :sql => sql, :binds => binds, :name => "REDIS", :connection_id => object_id) if @log_cached_queries
            @query_cache[sql][binds] = res
          # write to memory and redis from db and return
          else
            res = yield
            @query_cache[sql][binds] = res
            @redis.hset(sql, binds.to_s, res.to_json)
            @redis.expire(sql, @expires_in)
            res
          end

        result.collect { |row| row.dup }
      end
    end
  end
end
