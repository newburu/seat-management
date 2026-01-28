class Participant < ApplicationRecord
  belongs_to :event
  serialize :properties, coder: JSON
end
