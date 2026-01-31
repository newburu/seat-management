class Participant < ApplicationRecord
  belongs_to :event
  serialize :properties, coder: JSON
  
  validates :name, presence: true, length: { maximum: 20 }
end
