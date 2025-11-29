class PaymentsController < ApplicationController
  before_action :authenticate_user!

  def create
    @ride = Ride.find(params[:ride_id])

    # Ensure user is authorized to pay for this ride
    unless current_user == @ride.rider
      redirect_to root_path, alert: "Unauthorized access"
      return
    end

    # Ensure ride is completed before payment
    unless @ride.status == 'completed'
      redirect_to @ride, alert: "Ride must be completed before payment"
      return
    end

    begin
      # Create Stripe charge
      charge = Stripe::Charge.create({
        amount: (@ride.fare * 100).to_i, # Amount in cents
        currency: 'cad',
        source: params[:stripeToken],
        description: "Ride payment from #{@ride.pickup} to #{@ride.dropoff}",
        metadata: {
          ride_id: @ride.id,
          rider_id: @ride.rider_id,
          driver_id: @ride.driver_id
        }
      })

      # Create payment record
      payment = @ride.create_payment(
        amount: @ride.fare,
        status: 'succeeded',
        stripe_charge_id: charge.id
      )

      redirect_to @ride, notice: "Payment successful!"
    rescue Stripe::CardError => e
      redirect_to @ride, alert: "Payment failed: #{e.message}"
    rescue => e
      redirect_to @ride, alert: "An error occurred: #{e.message}"
    end
  end

  def refund
    @payment = Payment.find(params[:id])

    # Only admins can refund
    unless current_user.admin?
      redirect_to root_path, alert: "Unauthorized access"
      return
    end

    begin
      refund = Stripe::Refund.create({
        charge: @payment.stripe_charge_id
      })

      @payment.update(status: 'refunded')
      redirect_to admin_payments_path, notice: "Payment refunded successfully"
    rescue Stripe::InvalidRequestError => e
      redirect_to admin_payments_path, alert: "Refund failed: #{e.message}"
    end
  end
end
