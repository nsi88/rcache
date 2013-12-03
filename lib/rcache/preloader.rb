module ActiveRecord
  module Associations
    class Preloader #:nodoc:
      def preload_hash(association)
        association.each do |parent, child|
          Preloader.new(records, parent, options).run
          Preloader.new(records.map { |record| record.send(parent) }.flatten, child, options.select { |k,v| k == :rcache_value }).run
        end
      end
    end
  end
end
