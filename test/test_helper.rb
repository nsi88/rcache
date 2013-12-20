$:.unshift File.expand_path('../lib', File.dirname(__FILE__))

require 'test/unit'
require 'shoulda-context'
require 'rcache'

MODELS = File.join(File.dirname(__FILE__), "models")
$LOAD_PATH.unshift(MODELS)
Dir[ File.join(MODELS, "*.rb") ].each do |model|
  model = File.basename(model, ".rb")
  autoload model.camelize.to_sym, model
end

ActiveRecord::Migration.verbose = false

def setup_db
  ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :database => ':memory:')

  ActiveRecord::Schema.define(:version => 1) do
    create_table :clients do |t|
      t.string :name
    end

    create_table :events do |t|
      t.string :name
      t.integer :client_id
    end

    create_table :quotes do |t|
      t.string :name
      t.integer :client_id
    end
  end
end

def seed_db
  clients = Client.create([{ :name => 'client1' }, { :name => 'client2' }])
  3.times do |n|
    event = Event.create(:name => "event#{n + 1}", :client => clients.sample)
    Quote.create(:name => "quote#{n + 1}", :event => event)
  end
end

def teardown_db
  ActiveRecord::Base.connection.tables.each do |table|
    ActiveRecord::Base.connection.drop_table(table)
  end
end
