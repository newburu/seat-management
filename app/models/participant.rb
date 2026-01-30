class Participant < ApplicationRecord
  belongs_to :event
  serialize :properties, coder: JSON
  
  validates :name, presence: true
end
