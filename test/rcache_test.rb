require 'test_helper'

class RcacheTest < Test::Unit::TestCase
  context 'rcache' do
    setup do
      setup_db
      seed_db
    end

    context 'without rcache' do
      should 'return from db' do
        puts Client.all.inspect
        assert true
      end
    end

    teardown do 
      teardown_db
    end
  end
end
