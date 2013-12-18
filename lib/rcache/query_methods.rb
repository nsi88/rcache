module ActiveRecord
  module QueryMethods
    def rcache(opts = {})
      relation = clone
      relation.rcache_value = opts
      relation
    end
  end
end
