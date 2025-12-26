class Rating < ApplicationRecord
  belongs_to :ride
  belongs_to :rater, class_name: 'User'
  belongs_to :ratee, class_name: 'User'

  validates :score, presence: true, inclusion: { in: 1..5, message: 'must be between 1 and 5' }
  validates :ride_id, uniqueness: { message: 'has already been rated' }
end
