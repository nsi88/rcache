class Event < ActiveRecord::Base
  belongs_to :client
  has_many :quotes
end
