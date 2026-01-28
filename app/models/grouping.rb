class Grouping < ApplicationRecord
  belongs_to :event
  serialize :result, coder: JSON

end
