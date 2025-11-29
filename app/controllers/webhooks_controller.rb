class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def stripe
    payload = request.body.read
    sig_header = request.env['HTTP_STRIPE_SIGNATURE']
    endpoint_secret = ENV['STRIPE_WEBHOOK_SECRET']

    begin
      event = Stripe::Webhook.construct_event(
        payload, sig_header, endpoint_secret
      )
    rescue JSON::ParserError => e
      render json: { error: 'Invalid payload' }, status: 400
      return
    rescue Stripe::SignatureVerificationError => e
      render json: { error: 'Invalid signature' }, status: 400
      return
    end

    # Handle the event
    case event.type
    when 'charge.succeeded'
      handle_charge_succeeded(event.data.object)
    when 'charge.failed'
      handle_charge_failed(event.data.object)
    when 'charge.refunded'
      handle_charge_refunded(event.data.object)
    end

    render json: { message: 'success' }, status: 200
  end

  private

  def handle_charge_succeeded(charge)
    if charge.metadata.subscription_id
      subscription = Subscription.find_by(stripe_subscription_id: charge.id)
      subscription&.update(status: 'active')
    elsif charge.metadata.ride_id
      ride = Ride.find_by(id: charge.metadata.ride_id)
      payment = ride&.payment
      payment&.update(status: 'succeeded')
    end
  end

  def handle_charge_failed(charge)
    if charge.metadata.subscription_id
      subscription = Subscription.find_by(stripe_subscription_id: charge.id)
      subscription&.update(status: 'failed')
    elsif charge.metadata.ride_id
      ride = Ride.find_by(id: charge.metadata.ride_id)
      payment = ride&.payment
      payment&.update(status: 'failed')
    end
  end

  def handle_charge_refunded(charge)
    if charge.metadata.ride_id
      ride = Ride.find_by(id: charge.metadata.ride_id)
      payment = ride&.payment
      payment&.update(status: 'refunded')
    end
  end
end
