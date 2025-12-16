# Clear existing data (only in development)
if Rails.env.development?
  puts "Clearing existing data..."
  Payment.destroy_all
  Ride.destroy_all
  Vehicle.destroy_all
  KycDocument.destroy_all
  Subscription.destroy_all
  User.destroy_all
  puts "✓ Data cleared"
end

# Create Admin User
puts "\nCreating admin user..."
admin = User.create!(
  email: 'admin@trego.com',
  password: 'password123',
  password_confirmation: 'password123',
  name: 'Admin User',
  phone: '+1234567890',
  role: 'admin',
  is_admin: true,
  approved: true
)
puts "✓ Admin created: #{admin.email}"

# Create Customer Accounts
puts "\nCreating customer accounts..."
customers = []

customer1 = User.create!(
  email: 'customer1@test.com',
  password: 'password123',
  password_confirmation: 'password123',
  name: 'John Smith',
  phone: '+1234567891',
  role: 'customer',
  approved: true,
  current_latitude: 40.7128,
  current_longitude: -74.0060
)
customers << customer1

customer2 = User.create!(
  email: 'customer2@test.com',
  password: 'password123',
  password_confirmation: 'password123',
  name: 'Sarah Johnson',
  phone: '+1234567892',
  role: 'customer',
  approved: true,
  current_latitude: 40.7589,
  current_longitude: -73.9851
)
customers << customer2

customer3 = User.create!(
  email: 'customer3@test.com',
  password: 'password123',
  password_confirmation: 'password123',
  name: 'Michael Brown',
  phone: '+1234567893',
  role: 'customer',
  approved: true,
  current_latitude: 40.7489,
  current_longitude: -73.9680
)
customers << customer3

puts "✓ Created #{customers.count} customers"

# Create Driver Accounts
puts "\nCreating driver accounts..."
drivers = []

# Driver 1 - Fully approved and ready
driver1 = User.create!(
  email: 'driver1@test.com',
  password: 'password123',
  password_confirmation: 'password123',
  name: 'David Wilson',
  phone: '+1234567894',
  role: 'driver',
  approved: true,
  available: true,
  kyc_status: 'approved',
  current_latitude: 40.7300,
  current_longitude: -73.9950
)
drivers << driver1

# Create subscription for driver1
subscription1 = Subscription.create!(
  user: driver1,
  plan_type: 'monthly',
  amount: 50.0,
  starts_at: Time.current,
  ends_at: 1.month.from_now,
  status: 'active',
  stripe_subscription_id: 'sub_test_1'
)
puts "  ✓ Created subscription for #{driver1.name}"

# Create vehicle for driver1
vehicle1 = Vehicle.create!(
  user: driver1,
  make: 'Toyota',
  model: 'Camry',
  plate: 'ABC-1234',
  color: 'Silver',
  approved: true
)
puts "  ✓ Created vehicle for #{driver1.name}"

# Driver 2 - Approved with weekly subscription
driver2 = User.create!(
  email: 'driver2@test.com',
  password: 'password123',
  password_confirmation: 'password123',
  name: 'Emily Davis',
  phone: '+1234567895',
  role: 'driver',
  approved: true,
  available: true,
  kyc_status: 'approved',
  current_latitude: 40.7580,
  current_longitude: -73.9855
)
drivers << driver2

# Create subscription for driver2
subscription2 = Subscription.create!(
  user: driver2,
  plan_type: 'weekly',
  amount: 10.0,
  starts_at: Time.current,
  ends_at: 1.week.from_now,
  status: 'active',
  stripe_subscription_id: 'sub_test_2'
)
puts "  ✓ Created subscription for #{driver2.name}"

# Create vehicle for driver2
vehicle2 = Vehicle.create!(
  user: driver2,
  make: 'Honda',
  model: 'Accord',
  plate: 'XYZ-5678',
  color: 'Black',
  approved: true
)
puts "  ✓ Created vehicle for #{driver2.name}"

# Driver 3 - Pending approval (new driver)
driver3 = User.create!(
  email: 'driver3@test.com',
  password: 'password123',
  password_confirmation: 'password123',
  name: 'Robert Martinez',
  phone: '+1234567896',
  role: 'driver',
  approved: false,
  available: false,
  kyc_status: 'pending',
  current_latitude: 40.7400,
  current_longitude: -73.9900
)
drivers << driver3

# Create subscription for driver3
subscription3 = Subscription.create!(
  user: driver3,
  plan_type: 'monthly',
  amount: 50.0,
  starts_at: Time.current,
  ends_at: 1.month.from_now,
  status: 'active',
  stripe_subscription_id: 'sub_test_3'
)
puts "  ✓ Created subscription for #{driver3.name}"

# Create vehicle for driver3 (pending approval)
vehicle3 = Vehicle.create!(
  user: driver3,
  make: 'Ford',
  model: 'Focus',
  plate: 'DEF-9012',
  color: 'Blue',
  approved: false
)
puts "  ✓ Created vehicle for #{driver3.name} (pending approval)"

puts "✓ Created #{drivers.count} drivers"

# Create Sample Rides
puts "\nCreating sample rides..."

# Temporarily disable geocoding callbacks for seed data
Ride.skip_callback(:validation, :after, :geocode_pickup)
Ride.skip_callback(:validation, :after, :geocode_dropoff)

# Completed ride with payment
ride1 = Ride.create!(
  rider: customer1,
  driver: driver1,
  pickup: '123 Main St, New York, NY',
  dropoff: '456 Broadway, New York, NY',
  pickup_latitude: 40.7128,
  pickup_longitude: -74.0060,
  dropoff_latitude: 40.7589,
  dropoff_longitude: -73.9851,
  fare: 25.50,
  status: 'completed',
  created_at: 2.days.ago
)

# Create payment for ride1
payment1 = Payment.create!(
  ride: ride1,
  amount: 25.50,
  stripe_charge_id: 'ch_test_1',
  status: 'succeeded',
  created_at: 2.days.ago
)
puts "✓ Created completed ride with payment"

# In progress ride
ride2 = Ride.create!(
  rider: customer2,
  driver: driver2,
  pickup: '789 Park Ave, New York, NY',
  dropoff: '321 5th Ave, New York, NY',
  pickup_latitude: 40.7589,
  pickup_longitude: -73.9851,
  dropoff_latitude: 40.7489,
  dropoff_longitude: -73.9680,
  fare: 18.75,
  status: 'in_progress',
  created_at: 1.hour.ago
)
puts "✓ Created in-progress ride"

# Accepted ride
ride3 = Ride.create!(
  rider: customer3,
  driver: driver1,
  pickup: '555 Madison Ave, New York, NY',
  dropoff: '777 Lexington Ave, New York, NY',
  pickup_latitude: 40.7489,
  pickup_longitude: -73.9680,
  dropoff_latitude: 40.7300,
  dropoff_longitude: -73.9950,
  fare: 22.00,
  status: 'accepted',
  created_at: 30.minutes.ago
)
puts "✓ Created accepted ride"

# Requested ride (no driver assigned)
ride4 = Ride.create!(
  rider: customer1,
  driver: nil,
  pickup: '999 Central Park West, New York, NY',
  dropoff: '111 East 59th St, New York, NY',
  pickup_latitude: 40.7812,
  pickup_longitude: -73.9665,
  dropoff_latitude: 40.7614,
  dropoff_longitude: -73.9776,
  fare: 15.50,
  status: 'requested',
  created_at: 5.minutes.ago
)
puts "✓ Created requested ride (no driver)"

# Additional completed rides for history
5.times do |i|
  ride = Ride.create!(
    rider: customers.sample,
    driver: [driver1, driver2].sample,
    pickup: "Pickup Location #{i + 1}, New York, NY",
    dropoff: "Dropoff Location #{i + 1}, New York, NY",
    pickup_latitude: 40.7128 + (rand * 0.1),
    pickup_longitude: -74.0060 + (rand * 0.1),
    dropoff_latitude: 40.7589 + (rand * 0.1),
    dropoff_longitude: -73.9851 + (rand * 0.1),
    fare: (15 + rand * 30).round(2),
    status: 'completed',
    created_at: (i + 3).days.ago
  )

  Payment.create!(
    ride: ride,
    amount: ride.fare,
    stripe_charge_id: "ch_test_#{i + 2}",
    status: 'succeeded',
    created_at: (i + 3).days.ago
  )
end
puts "✓ Created 5 additional completed rides with payments"

# Re-enable geocoding callbacks
Ride.set_callback(:validation, :after, :geocode_pickup)
Ride.set_callback(:validation, :after, :geocode_dropoff)

puts "\n" + "="*50
puts "Seed data created successfully!"
puts "="*50
puts "\nTest Accounts:"
puts "\nAdmin:"
puts "  Email: admin@trego.com"
puts "  Password: password123"
puts "\nCustomers:"
puts "  Email: customer1@test.com | Password: password123"
puts "  Email: customer2@test.com | Password: password123"
puts "  Email: customer3@test.com | Password: password123"
puts "\nDrivers:"
puts "  Email: driver1@test.com | Password: password123 (✓ Fully Approved)"
puts "  Email: driver2@test.com | Password: password123 (✓ Fully Approved)"
puts "  Email: driver3@test.com | Password: password123 (⏳ Pending Approval)"
puts "\nSummary:"
puts "  - #{User.count} total users"
puts "  - #{User.customers.count} customers"
puts "  - #{User.drivers.count} drivers"
puts "  - #{Vehicle.count} vehicles"
puts "  - #{Subscription.count} subscriptions"
puts "  - #{Ride.count} rides"
puts "  - #{Payment.count} payments"
puts "="*50
