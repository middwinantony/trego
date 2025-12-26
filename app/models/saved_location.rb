class SavedLocation < ApplicationRecord
  belongs_to :user

  enum location_type: { home: 'home', work: 'work', custom: 'custom' }

  validates :name, presence: true
  validates :address, presence: true
  validates :latitude, presence: true, numericality: { greater_than_or_equal_to: -90, less_than_or_equal_to: 90 }
  validates :longitude, presence: true, numericality: { greater_than_or_equal_to: -180, less_than_or_equal_to: 180 }
  validates :location_type, presence: true
  validates :location_type, uniqueness: { scope: :user_id, message: 'already exists for this user' }, if: -> { home? || work? }
end
