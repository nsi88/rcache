require 'test_helper'

class RcacheTest < Test::Unit::TestCase
  context 'rcache' do
    setup do
      setup_db
      seed_db
    end

    context 'disabled' do
      should 'return from db' do
        assert Client.includes(:events => :quotes).first.events.map(&:quotes).flatten.any?
        ActiveRecord::Base.connection.execute('delete from quotes')
        assert Client.includes(:events => :quotes).first.events.map(&:quotes).flatten.empty?

        assert Client.first.events.count > 0
        ActiveRecord::Base.connection.execute('delete from events')
        assert Client.first.events.count == 0

        assert Client.first.present?
        ActiveRecord::Base.connection.execute('delete from clients')
        assert Client.first.nil?
      end
    end

    context 'enabled' do
      should 'return from cache' do
        assert Client.rcache.includes(:events => :quotes).first.events.map(&:quotes).flatten.any?
        ActiveRecord::Base.connection.execute('delete from quotes')
        assert Client.rcache.includes(:events => :quotes).first.events.map(&:quotes).flatten.any?
        teardown_redis
        assert Client.rcache.includes(:events => :quotes).first.events.map(&:quotes).flatten.empty?

        assert Client.first.events.rcache.count > 0
        ActiveRecord::Base.connection.execute('delete from events')
        assert Client.first.events.rcache.count > 0
        teardown_redis
        assert Client.first.events.rcache.count == 0

        assert Client.rcache.first.present?
        ActiveRecord::Base.connection.execute('delete from clients')
        assert Client.rcache.first.present?
        teardown_redis
        assert Client.rcache.first.nil?
      end
    end

    teardown do
      teardown_db
      teardown_redis
    end
  end
end
