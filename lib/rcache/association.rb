module ActiveRecord
  module Associations
    class Preloader
      class Association #:nodoc:
        alias :old_build_scope :build_scope

        def build_scope
          scope = old_build_scope
          scope = scope.rcache(preload_options[:rcache_value]) if preload_options[:rcache_value]
          scope
        end
      end
    end
  end
end
