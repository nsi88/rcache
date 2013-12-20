require "rcache/version"
require "json"
require "active_record"
require "redis"
require "digest/md5"
require "rcache/query_cache"
require "rcache/query_methods"
require "rcache/relation"
require "rcache/association"
require "rcache/querying"
require "rcache/preloader"
require "rcache/arel"

module Rcache
  class << self
    attr_accessor :redis, :expires_in, :log_cached_queries, :key_prefix

    def configure
      yield self
    end
  end

  self.expires_in = 60
  self.log_cached_queries = true
  self.key_prefix = 'rcache::'
end
