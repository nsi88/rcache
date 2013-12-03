module ActiveRecord
  module Querying
    delegate :rcache, :to => :scoped
  end
end
