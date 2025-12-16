class Vehicle < ApplicationRecord
  belongs_to :user

  validates :make, presence: true
  validates :model, presence: true
  validates :plate, presence: true, uniqueness: true
  validates :color, presence: true

  scope :approved, -> { where(approved: true) }
  scope :pending, -> { where(approved: false) }
end
