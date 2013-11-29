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
      connection.rcache_value = @rcache_value
      super_build_arel
    end
  end
end
