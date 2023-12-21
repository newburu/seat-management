class Seat < ApplicationRecord
  belongs_to :event
  belongs_to :attendee

  validates :no, uniqueness: { scope: :event_id }
end
