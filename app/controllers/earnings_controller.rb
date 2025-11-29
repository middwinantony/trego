class EarningsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_driver

  def index
    @earnings = current_user.earnings_breakdown
    @recent_rides = current_user.rides_as_driver
                                .completed
                                .joins(:payment)
                                .includes(:rider, :payment)
                                .order(created_at: :desc)
                                .limit(20)

    # Group earnings by date for chart
    @daily_earnings = current_user.rides_as_driver
                                  .completed
                                  .joins(:payment)
                                  .where('rides.created_at >= ?', 30.days.ago)
                                  .where(payments: { status: 'succeeded' })
                                  .group("DATE(rides.created_at)")
                                  .sum('payments.amount')
  end

  private

  def ensure_driver
    unless current_user.driver?
      redirect_to root_path, alert: "Only drivers can view earnings"
    end
  end
end
