module Admin
  class DashboardController < BaseController
    def index
      @stats = {
        total_users: User.count,
        total_drivers: User.drivers.count,
        total_customers: User.customers.count,
        pending_drivers: User.pending_approval.count,
        total_rides: Ride.count,
        completed_rides: Ride.completed.count,
        active_rides: Ride.active.count,
        total_revenue: Payment.where(status: 'succeeded').sum(:amount),
        active_subscriptions: Subscription.active.count
      }

      @recent_rides = Ride.order(created_at: :desc).limit(10)
      @pending_drivers = User.pending_approval.limit(5)
    end
  end
end
