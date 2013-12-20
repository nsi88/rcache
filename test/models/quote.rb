class Quote < ActiveRecord::Base
  belongs_to :event

  default_scope order(:name)
end
