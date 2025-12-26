class RidePricingService
  RIDE_TYPE_MULTIPLIERS = {
    'economy' => 1.0,
    'comfort' => 1.3,
    'premium' => 1.8,
    'xl' => 1.5
  }.freeze

  RIDE_TYPE_INFO = {
    'economy' => { name: 'Economy', capacity: 4, description: 'Affordable rides' },
    'comfort' => { name: 'Comfort', capacity: 4, description: 'Newer cars with extra legroom' },
    'premium' => { name: 'Premium', capacity: 4, description: 'High-end cars and top-rated drivers' },
    'xl' => { name: 'XL', capacity: 6, description: 'Rides for groups up to 6' }
  }.freeze

  def initialize(ride)
    @ride = ride
    @mapbox_service = MapboxService.new
  end

  # Calculate pricing and ETA for all ride types
  def calculate_all_options
    base_fare = 5.0
    per_km = 2.0
    distance = @ride.distance

    return default_unavailable_options unless distance

    RIDE_TYPE_MULTIPLIERS.map do |type, multiplier|
      fare = ((base_fare + (distance * per_km)) * multiplier).round(2)
      eta = calculate_eta

      [
        type,
        {
          name: RIDE_TYPE_INFO[type][:name],
          capacity: RIDE_TYPE_INFO[type][:capacity],
          description: RIDE_TYPE_INFO[type][:description],
          price: fare,
          eta: eta,
          available: check_availability(type)
        }
      ]
    end.to_h
  end

  # Calculate ETA in minutes
  def calculate_eta
    return 5 unless @ride.pickup_latitude && @ride.pickup_longitude

    # Get nearest driver location (simplified - in production would check actual driver locations)
    # For now, return a default ETA
    rand(3..8) # Random ETA between 3-8 minutes
  end

  private

  def check_availability(ride_type)
    # In production, check if drivers with this vehicle type are available
    # For now, return true for all types
    true
  end

  def default_unavailable_options
    RIDE_TYPE_MULTIPLIERS.keys.map do |type|
      [
        type,
        {
          name: RIDE_TYPE_INFO[type][:name],
          capacity: RIDE_TYPE_INFO[type][:capacity],
          description: RIDE_TYPE_INFO[type][:description],
          price: 0,
          eta: 0,
          available: false
        }
      ]
    end.to_h
  end
end
