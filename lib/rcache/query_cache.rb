module ActiveRecord
  module ConnectionAdapters # :nodoc:
    module QueryCache
      def select_all(arel, name = nil, binds = [])
        if (arel.rcache_value rescue false) && !locked?(arel) && (arel.rcache_value[:expires_in] || Rcache.expires_in).to_i > 0
          sql = to_sql(arel, binds)
          redis_cache_sql(arel.rcache_value, sql, binds) { super(sql, name, binds) }
            .collect { |row| row.dup }
        elsif @query_cache_enabled && !locked?(arel)
          sql = to_sql(arel, binds)
          cache_sql(sql, binds) { super(sql, name, binds) }
        else
          super
        end
      end

      def select_value(arel, name = nil)
        binds = []
        if (arel.rcache_value rescue false) && !locked?(arel) && (arel.rcache_value[:expires_in] || Rcache.expires_in).to_i > 0
          sql = to_sql(arel, binds)
          redis_cache_sql(arel.rcache_value, sql, binds) { super(sql, name) }
        else
          super
        end
      end

      private

      def redis_cache_sql(rcache_value, sql, binds)
        [:redis, :expires_in, :log_cached_queries, :key_prefix].each do |attr|
          instance_variable_set("@#{attr}", rcache_value.has_key?(attr) ? rcache_value[attr] : Rcache.send(attr))
        end

        # return from memory
        if @query_cache_enabled && @query_cache[sql].key?(binds)
          ActiveSupport::Notifications.instrument("sql.active_record", :sql => sql, :binds => binds, :name => "CACHE", :connection_id => object_id) if @log_cached_queries
          @query_cache[sql][binds]
        # write to memory from redis and return
        else
          res = @redis.get(redis_cache_key(sql, binds, @key_prefix))
          if res
            begin
              res = JSON.parse(res)
            rescue JSON::ParserError
            end
            ActiveSupport::Notifications.instrument("sql.active_record", :sql => sql, :binds => binds, :name => "REDIS", :connection_id => object_id) if @log_cached_queries
            @query_cache[sql][binds] = res
          else
            # write to memory and redis from db and return
            res = yield
            @query_cache[sql][binds] = res
            @redis.setex(redis_cache_key(sql, binds, @key_prefix), @expires_in, res.to_json)
            res
          end
        end
      end

      def redis_cache_key(sql, binds, key_prefix)
        key_prefix + Digest::MD5.hexdigest(sql + binds.to_s)
      end
    end
  end
end
