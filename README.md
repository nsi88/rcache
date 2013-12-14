# Rcache

Caches activerecord query results to memory and redis

## Installation

Add this line to your application's Gemfile:

    gem 'rcache'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rcache

In your initializers:

  Rcache.configure do |config|
    config.redis = <your connect to redis>
  end

Optional settings:

1. expires_in (default 60)
2. log_cached_queries (default true)
3. key_prefix (default rcache::)


## Usage

Cache find result for 60 seconds:

  Client.rcache.find(2)

Cache where results with includes for 10 seconds and not show cached queries in log:

  Event.limit(2).includes(:thumbnails, :type => :variable).rcache(:expires_in => 10.seconds, :log_cached_queries => false)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
