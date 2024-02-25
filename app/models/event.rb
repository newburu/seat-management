class Event < ApplicationRecord
  belongs_to :user
  has_many :attendees, dependent: :destroy
  has_many :seats, dependent: :destroy
end
