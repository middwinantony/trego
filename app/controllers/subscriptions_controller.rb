class SubscriptionsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_driver

  def new
    @subscription = Subscription.new
  end

  def create
    @subscription = current_user.subscriptions.build(subscription_params)

    plan = Subscription::PLAN_TYPES[subscription_params[:plan_type].to_sym]
    @subscription.amount = plan[:amount]
    @subscription.status = 'active'
    @subscription.starts_at = Time.current
    @subscription.ends_at = Time.current + plan[:duration]

    if @subscription.save
      redirect_to dashboard_path, notice: "Subscription activated successfully! You can now accept rides."
    else
      render :new, alert: "Could not create subscription"
    end
  end

  def index
    @subscriptions = current_user.subscriptions.order(created_at: :desc)
  end

  private

  def subscription_params
    params.require(:subscription).permit(:plan_type)
  end

  def ensure_driver
    unless current_user.driver?
      redirect_to root_path, alert: "Only drivers can access subscriptions"
    end
  end
end
