class KycDocument < ApplicationRecord
  belongs_to :user
  has_one_attached :file

  DOCUMENT_TYPES = %w[drivers_license passport vehicle_registration vehicle_insurance proof_of_address].freeze
  STATUSES = %w[pending approved rejected].freeze

  validates :document_type, presence: true, inclusion: { in: DOCUMENT_TYPES }
  validates :status, presence: true, inclusion: { in: STATUSES }
  validates :file, attached: true, content_type: ['image/png', 'image/jpeg', 'application/pdf'],
                  size: { less_than: 10.megabytes }

  scope :pending, -> { where(status: 'pending') }
  scope :approved, -> { where(status: 'approved') }
  scope :rejected, -> { where(status: 'rejected') }
end
