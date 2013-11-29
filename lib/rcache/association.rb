module ActiveRecord
  module Associations
    class Preloader
      class Association #:nodoc:
        def build_scope
          scope = klass.scoped

          scope = scope.where(process_conditions(options[:conditions]))
          scope = scope.where(process_conditions(preload_options[:conditions]))

          scope = scope.select(preload_options[:select] || options[:select] || table[Arel.star])
          scope = scope.includes(preload_options[:include] || options[:include])

          if options[:as]
            scope = scope.where(
              klass.table_name => {
                reflection.type => model.base_class.sti_name
              }
            )
          end
          scope = scope.rcache(preload_options[:rcache_value]) if preload_options[:rcache_value]

          scope
        end
      end
    end
  end
end
