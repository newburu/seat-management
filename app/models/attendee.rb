class Attendee < ApplicationRecord
  belongs_to :event
  belongs_to :user
  has_one :seat, dependent: :destroy
end
