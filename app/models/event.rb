class Event < ApplicationRecord
  belongs_to :user
  has_many :participants, dependent: :destroy
  has_many :groupings, dependent: :destroy

end
