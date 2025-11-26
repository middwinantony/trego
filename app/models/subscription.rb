class Subscription < ApplicationRecord
  belongs_to :user

  PLAN_TYPES = {
    weekly: { name: 'Weekly', amount: 10.00, duration: 1.week },
    monthly: { name: 'Monthly', amount: 50.00, duration: 1.month }
  }.freeze

  validates :plan_type, presence: true, inclusion: { in: PLAN_TYPES.keys.map(&:to_s) }
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :status, presence: true, inclusion: { in: %w[active expired cancelled] }

  scope :active, -> { where(status: 'active').where('ends_at > ?', Time.current) }

  def active?
    status == 'active' && ends_at.present? && ends_at > Time.current
  end

  def expired?
    ends_at.present? && ends_at <= Time.current
  end
end
