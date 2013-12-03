module ActiveRecord
  module QueryMethods
    def rcache(opts = {})
      connection.rcache_value = opts
      self
    end
  end
end
