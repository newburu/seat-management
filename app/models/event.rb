class Event < ApplicationRecord
  belongs_to :user
  has_many :participants, dependent: :destroy
  has_many :groupings, dependent: :destroy

  validates :name, presence: true, length: { maximum: 50 }
end
