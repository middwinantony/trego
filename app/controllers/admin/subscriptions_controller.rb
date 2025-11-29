module Admin
  class SubscriptionsController < BaseController
    def index
      @subscriptions = Subscription.includes(:user).order(created_at: :desc)

      if params[:status].present?
        @subscriptions = @subscriptions.where(status: params[:status])
      end

      @subscriptions = @subscriptions.page(params[:page]).per(20) if defined?(Kaminari)
    end

    def show
      @subscription = Subscription.find(params[:id])
    end
  end
end
