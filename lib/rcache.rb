require "rcache/version"
require "json"
require "rcache/query_cache"
require "rcache/query_methods"
require "rcache/relation"
require "rcache/association"

module Rcache
  class << self
    attr_accessor :redis, :expires_in, :log_cached_queries

    def configure
      yield self
    end
  end

  self.expires_in = 60
  self.log_cached_queries = true
end
