module ActiveRecord
  module Calculations
    def execute_simple_calculation(operation, column_name, distinct) #:nodoc:
      # Postgresql doesn't like ORDER BY when there are no GROUP BY
      relation = reorder(nil)

      if operation == "count" && (relation.limit_value || relation.offset_value)
        # Shortcut when limit is zero.
        return 0 if relation.limit_value == 0

        query_builder = build_count_subquery(relation, column_name, distinct)
      else
        column = aggregate_column(column_name)

        select_value = operation_over_aggregate_column(column, operation, distinct)

        relation.select_values = [select_value]

        query_builder = relation.arel
      end
      query_builder.rcache_value = relation.rcache_value
      type_cast_calculated_value(@klass.connection.select_value(query_builder), column_for(column_name), operation)
    end
  end
end
