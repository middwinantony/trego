class Complaint < ApplicationRecord
  belongs_to :user
  belongs_to :ride, optional: true

  validates :subject, presence: true
  validates :description, presence: true
  validates :status, presence: true, inclusion: { in: %w[open in_progress resolved closed] }

  scope :open_complaints, -> { where(status: 'open') }
  scope :in_progress, -> { where(status: 'in_progress') }
  scope :resolved, -> { where(status: 'resolved') }
  scope :closed, -> { where(status: 'closed') }
end
