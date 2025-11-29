# Trego - Ride-Sharing Platform

A full-featured ride-sharing platform built with Ruby on Rails, featuring real-time tracking, payment processing, and comprehensive admin management.

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Technology Stack](#technology-stack)
- [Architecture](#architecture)
- [Database Schema](#database-schema)
- [Setup Instructions](#setup-instructions)
- [Environment Variables](#environment-variables)
- [Key Features Implementation](#key-features-implementation)
- [API Endpoints](#api-endpoints)
- [Real-Time Features](#real-time-features)
- [Payment Integration](#payment-integration)
- [Admin Panel](#admin-panel)
- [File Structure](#file-structure)
- [Testing](#testing)
- [Deployment](#deployment)

---

## Overview

Trego is a comprehensive ride-sharing platform that connects riders with drivers. The platform includes subscription-based driver access, real-time location tracking, integrated payment processing, KYC verification, and a robust admin panel for platform management.

### User Roles

- **Customers**: Request rides, make payments, track drivers in real-time
- **Drivers**: Accept rides, manage availability, track earnings, upload KYC documents
- **Admins**: Manage platform, approve drivers/vehicles, handle complaints, review KYC documents

---

## Features

### Core Functionality

- ✅ User authentication with role-based access (Devise)
- ✅ Separate registration flows for customers and drivers
- ✅ Driver subscription system (weekly/monthly plans)
- ✅ Ride request and matching system
- ✅ Real-time ride status updates
- ✅ Driver availability management

### Payment & Billing

- ✅ Stripe integration for ride payments
- ✅ Subscription billing for drivers
- ✅ Automated fare calculation based on distance
- ✅ Payment history and tracking
- ✅ Webhook handling for payment events
- ✅ Refund functionality (admin)

### Real-Time Features

- ✅ ActionCable WebSocket connections
- ✅ Live driver location tracking
- ✅ Real-time ride status updates
- ✅ Push notifications for ride events
- ✅ Live driver matching

### Driver Management

- ✅ KYC document upload and verification
- ✅ Vehicle registration and approval
- ✅ Driver approval workflow
- ✅ Earnings dashboard with detailed breakdown
- ✅ Ride history and statistics

### Location & Mapping

- ✅ Geocoding with Geocoder gem
- ✅ Mapbox integration for route visualization
- ✅ Distance-based fare calculation
- ✅ Real-time driver location updates
- ✅ Interactive maps with pickup/dropoff markers

### Admin Panel

- ✅ Comprehensive dashboard with platform statistics
- ✅ Driver approval/rejection workflow
- ✅ Vehicle approval system
- ✅ KYC document review with image preview
- ✅ Ride monitoring and management
- ✅ Subscription oversight
- ✅ Complaints management system
- ✅ Payment refund capabilities

### Support System

- ✅ Complaint submission and tracking
- ✅ Status management (open, in_progress, resolved, closed)
- ✅ Ride-linked complaints
- ✅ Admin complaint review

---

## Technology Stack

### Backend

- **Ruby**: 3.3.5
- **Rails**: 7.1.6
- **Database**: PostgreSQL
- **ORM**: ActiveRecord
- **Authentication**: Devise
- **Real-time**: ActionCable with Redis
- **Background Jobs**: Active Job (ready for Sidekiq)

### Frontend

- **CSS Framework**: Tailwind CSS
- **JavaScript**: Hotwire (Turbo + Stimulus)
- **Module System**: Importmap
- **Maps**: Mapbox GL JS

### Third-Party Services

- **Payment Processing**: Stripe
- **Geocoding**: Nominatim (via Geocoder gem)
- **Maps**: Mapbox
- **File Storage**: Active Storage
- **WebSockets**: Redis

### Development Tools

- **Ruby Version Manager**: rbenv
- **Package Manager**: Bundler
- **Asset Pipeline**: Sprockets

---

## Architecture

### MVC Pattern

The application follows Ruby on Rails' MVC (Model-View-Controller) architecture:

```
app/
├── models/           # Business logic and data models
├── controllers/      # Request handling and flow control
├── views/            # HTML templates (ERB)
├── channels/         # ActionCable WebSocket channels
├── services/         # Business logic services
└── assets/           # CSS, JavaScript, images
```

### Key Architectural Decisions

1. **Role-Based Access Control**: Implemented through user roles (customer, driver, admin)
2. **Approval Workflows**: Drivers and vehicles require admin approval before operation
3. **Subscription Model**: Drivers must maintain active subscriptions to accept rides
4. **Real-Time Architecture**: ActionCable for live updates with Redis as message broker
5. **Payment Flow**: Rides completed → Payment processed → Earnings tracked
6. **KYC Verification**: Document upload → Admin review → Driver approval

---

## Database Schema

### Core Models

#### Users Table
```ruby
- email (string)
- encrypted_password (string)
- name (string)
- phone (string)
- role (string) # customer, driver, admin
- available (boolean)
- approved (boolean)
- kyc_status (string) # pending, submitted, approved, rejected
- is_admin (boolean)
- current_latitude (decimal)
- current_longitude (decimal)
```

#### Rides Table
```ruby
- rider_id (foreign_key → users)
- driver_id (foreign_key → users, optional)
- pickup (string)
- dropoff (string)
- status (string) # requested, accepted, in_progress, completed, cancelled
- fare (decimal)
- pickup_latitude (decimal)
- pickup_longitude (decimal)
- dropoff_latitude (decimal)
- dropoff_longitude (decimal)
```

#### Subscriptions Table
```ruby
- user_id (foreign_key → users)
- plan_type (string) # weekly, monthly
- amount (decimal)
- status (string) # active, expired, cancelled
- starts_at (datetime)
- ends_at (datetime)
- stripe_subscription_id (string)
```

#### Vehicles Table
```ruby
- user_id (foreign_key → users)
- make (string)
- model (string)
- plate (string)
- color (string)
- approved (boolean)
```

#### Payments Table
```ruby
- ride_id (foreign_key → rides)
- amount (decimal)
- status (string) # succeeded, failed, refunded
- stripe_charge_id (string)
```

#### KYC Documents Table
```ruby
- user_id (foreign_key → users)
- document_type (string) # drivers_license, passport, vehicle_registration, etc.
- status (string) # pending, approved, rejected
- file (active_storage_attachment)
```

#### Complaints Table
```ruby
- user_id (foreign_key → users)
- ride_id (foreign_key → rides, optional)
- subject (string)
- description (text)
- status (string) # open, in_progress, resolved, closed
```

### Associations

```ruby
User
  has_one :vehicle
  has_many :subscriptions
  has_one :current_subscription
  has_many :rides_as_rider
  has_many :rides_as_driver
  has_many :complaints
  has_many :kyc_documents

Ride
  belongs_to :rider (User)
  belongs_to :driver (User, optional)
  has_one :payment

Subscription
  belongs_to :user

Vehicle
  belongs_to :user

Payment
  belongs_to :ride

KycDocument
  belongs_to :user
  has_one_attached :file

Complaint
  belongs_to :user
  belongs_to :ride (optional)
```

---

## Setup Instructions

### Prerequisites

- Ruby 3.3.5
- PostgreSQL
- Redis (for ActionCable)
- Node.js (for asset compilation)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd trego
   ```

2. **Install dependencies**
   ```bash
   bundle install
   ```

3. **Setup database**
   ```bash
   rails db:create
   rails db:migrate
   rails db:seed # if you have seed data
   ```

4. **Install Redis** (if not already installed)
   ```bash
   # macOS
   brew install redis
   brew services start redis

   # Ubuntu
   sudo apt-get install redis-server
   sudo systemctl start redis
   ```

5. **Configure environment variables**
   ```bash
   cp .env.example .env
   # Edit .env with your credentials
   ```

6. **Start the Rails server**
   ```bash
   rails server
   ```

7. **Start Redis server** (if not running as service)
   ```bash
   redis-server
   ```

8. **Access the application**
   - Open browser: http://localhost:3000
   - Admin access: Create admin user via Rails console

### Creating an Admin User

```ruby
rails console

User.create!(
  email: 'admin@trego.com',
  password: 'password123',
  name: 'Admin User',
  phone: '+1234567890',
  role: 'admin',
  is_admin: true,
  approved: true
)
```

---

## Environment Variables

Create a `.env` file in the root directory:

```bash
# Stripe Configuration
STRIPE_PUBLISHABLE_KEY=pk_test_your_publishable_key
STRIPE_SECRET_KEY=sk_test_your_secret_key
STRIPE_WEBHOOK_SECRET=whsec_your_webhook_secret

# Mapbox Configuration
MAPBOX_ACCESS_TOKEN=pk.eyJ1your_mapbox_token

# Redis Configuration (optional, defaults to localhost)
REDIS_URL=redis://localhost:6379/1

# Database Configuration (if not using database.yml)
DATABASE_URL=postgresql://username:password@localhost/trego_development
```

### Getting API Keys

1. **Stripe**: Sign up at https://stripe.com/
   - Get test keys from Dashboard → Developers → API keys
   - Set up webhooks for production

2. **Mapbox**: Sign up at https://www.mapbox.com/
   - Get free access token from Account → Access tokens
   - Free tier includes 50,000 requests/month

---

## Key Features Implementation

### 1. Ride Matching Algorithm

Location: `app/services/ride_matching_service.rb`

The ride matching service finds nearby available drivers and notifies them of new ride requests:

```ruby
# Find drivers within 10km radius
nearby_drivers = User.nearby_drivers(ride.pickup_latitude, ride.pickup_longitude, 10)

# Broadcast notification to all nearby drivers
nearby_drivers.each do |driver|
  NotificationChannel.broadcast_to(driver, ride_data)
end
```

**Algorithm Features:**
- Distance-based driver filtering
- Subscription status validation
- Approval status verification
- Availability checking
- Sorted by proximity

### 2. Fare Calculation

Location: `app/models/ride.rb`

Automatic fare calculation based on distance:

```ruby
def calculate_fare
  base_fare = 5.0  # $5 base fare
  per_km = 2.0     # $2 per km

  distance = Geocoder::Calculations.distance_between(
    [pickup_latitude, pickup_longitude],
    [dropoff_latitude, dropoff_longitude]
  )

  (base_fare + (distance * per_km)).round(2)
end
```

### 3. Real-Time Location Tracking

**Driver Side:**
```javascript
// Driver's app continuously sends location
navigator.geolocation.watchPosition((position) => {
  fetch('/drivers/:id/update_location', {
    method: 'POST',
    body: JSON.stringify({
      latitude: position.coords.latitude,
      longitude: position.coords.longitude
    })
  });
});
```

**Rider Side:**
```javascript
// Rider subscribes to ride channel
consumer.subscriptions.create({ channel: 'RideChannel', ride_id: rideId }, {
  received(data) {
    if (data.type === 'driver_location') {
      updateDriverMarker(data.latitude, data.longitude);
    }
  }
});
```

### 4. Subscription Management

Drivers must maintain active subscriptions:

```ruby
def can_accept_rides?
  driver? &&
  available? &&
  has_active_subscription? &&
  approved?
end
```

**Subscription Plans:**
- **Weekly**: $10/week
- **Monthly**: $50/month (save 50%)

### 5. Payment Processing

**Ride Payment Flow:**
1. Ride completed by driver
2. Rider prompted to pay
3. Stripe token generated on frontend
4. Backend processes charge
5. Payment record created
6. Earnings updated for driver

**Code Example:**
```ruby
charge = Stripe::Charge.create({
  amount: (ride.fare * 100).to_i, # cents
  currency: 'cad',
  source: stripe_token,
  description: "Ride payment",
  metadata: { ride_id: ride.id }
})
```

### 6. KYC Verification

**Required Documents:**
- Driver's License
- Vehicle Registration
- Vehicle Insurance
- Proof of Address (optional)
- Passport (optional)

**Workflow:**
1. Driver uploads document via Active Storage
2. Admin reviews document in admin panel
3. Admin approves/rejects
4. Driver KYC status updated
5. Automatic driver approval when all required docs approved

---

## API Endpoints

### Public Routes

```
GET    /                          # Home page
GET    /users/sign_up             # Registration
POST   /users                     # Create user
GET    /users/sign_in             # Login
POST   /users/sign_in             # Authenticate
DELETE /users/sign_out            # Logout
```

### Customer Routes

```
GET    /rides                     # List rides
GET    /rides/new                 # New ride form
POST   /rides                     # Create ride
GET    /rides/:id                 # Ride details
PATCH  /rides/:id                 # Update ride status

POST   /payments                  # Process payment
GET    /complaints                # List complaints
GET    /complaints/new            # New complaint form
POST   /complaints                # Create complaint
```

### Driver Routes

```
GET    /dashboard                 # Driver dashboard
GET    /subscriptions/new         # Choose subscription plan
POST   /subscriptions             # Activate subscription
GET    /subscriptions             # Subscription history

GET    /kyc_documents             # List KYC documents
GET    /kyc_documents/new         # Upload document form
POST   /kyc_documents             # Upload document

GET    /earnings                  # Earnings dashboard

PATCH  /drivers/:id               # Update availability
POST   /drivers/:id/update_location  # Update GPS location
```

### Admin Routes

All admin routes are under `/admin` namespace and require admin authentication:

```
GET    /admin                     # Admin dashboard
GET    /admin/drivers             # List drivers
GET    /admin/drivers/:id         # Driver details
POST   /admin/drivers/:id/approve # Approve driver
POST   /admin/drivers/:id/reject  # Reject driver

GET    /admin/vehicles            # List vehicles
POST   /admin/vehicles/:id/approve
POST   /admin/vehicles/:id/reject

GET    /admin/rides               # List all rides
GET    /admin/rides/:id           # Ride details

GET    /admin/kyc_documents       # List KYC documents
GET    /admin/kyc_documents/:id   # Review document
POST   /admin/kyc_documents/:id/approve
POST   /admin/kyc_documents/:id/reject

GET    /admin/complaints          # List complaints
GET    /admin/complaints/:id      # Complaint details
PATCH  /admin/complaints/:id      # Update complaint status

GET    /admin/subscriptions       # List subscriptions
```

### WebSocket Channels

```
RideChannel              # Real-time ride updates
  - Location updates
  - Status changes

NotificationChannel      # User notifications
  - Ride requests
  - Driver assignments
  - Ride status changes
```

---

## Real-Time Features

### ActionCable Architecture

**Connection Authentication:**
```ruby
# app/channels/application_cable/connection.rb
def connect
  self.current_user = find_verified_user
end
```

**Ride Channel:**
```ruby
# Subscribe to ride updates
RideChannel.broadcast_to(ride, {
  type: 'status_update',
  status: ride.status,
  driver: ride.driver.name
})
```

**Notification Channel:**
```ruby
# Broadcast to specific user
NotificationChannel.broadcast_to(user, {
  type: 'ride_request',
  ride_id: ride.id,
  pickup: ride.pickup
})
```

### Redis Configuration

Development uses Redis for ActionCable:
```yaml
# config/cable.yml
development:
  adapter: redis
  url: redis://localhost:6379/1
```

---

## Payment Integration

### Stripe Setup

1. **Initialization**: `config/initializers/stripe.rb`
2. **Payment Controller**: Handles charge creation
3. **Webhook Controller**: Processes Stripe events
4. **Frontend**: Stripe Elements for secure card input

### Payment Flow Diagram

```
Ride Completed
    ↓
Rider sees payment prompt
    ↓
Stripe Elements collects card data
    ↓
Token sent to backend
    ↓
Charge created via Stripe API
    ↓
Payment record saved
    ↓
Driver earnings updated
```

### Webhook Events Handled

- `charge.succeeded`: Payment successful
- `charge.failed`: Payment failed
- `charge.refunded`: Payment refunded

### Testing Stripe

Use Stripe test cards:
- Success: `4242 4242 4242 4242`
- Decline: `4000 0000 0000 0002`
- Any future expiry, any CVC

---

## Admin Panel

### Dashboard Features

- **Statistics Cards:**
  - Total users (drivers/customers)
  - Pending driver approvals
  - Total rides (completed/active)
  - Total revenue

- **Recent Activity:**
  - Latest rides
  - Pending driver approvals (quick approve/reject)

### Driver Management

- View all drivers with filtering
- Approve/reject drivers
- View driver details:
  - Personal information
  - Vehicle details
  - Subscription status
  - Ride history
  - Earnings

### Vehicle Approval

- Grid view of all vehicles
- Approve/reject vehicles
- Driver association

### KYC Document Review

- List all documents with status filtering
- Image preview for uploaded documents
- Approve/reject documents
- Automatic driver approval logic

### Ride Monitoring

- View all platform rides
- Filter by status
- Access ride details
- View payment information

### Complaint Management

- View all complaints
- Update complaint status
- Link to related rides
- Track resolution

---

## File Structure

```
trego/
├── app/
│   ├── channels/
│   │   ├── application_cable/
│   │   │   ├── channel.rb
│   │   │   └── connection.rb         # WebSocket authentication
│   │   ├── notification_channel.rb   # User notifications
│   │   └── ride_channel.rb           # Ride updates
│   │
│   ├── controllers/
│   │   ├── admin/
│   │   │   ├── base_controller.rb    # Admin authentication
│   │   │   ├── dashboard_controller.rb
│   │   │   ├── drivers_controller.rb
│   │   │   ├── vehicles_controller.rb
│   │   │   ├── rides_controller.rb
│   │   │   ├── kyc_documents_controller.rb
│   │   │   ├── complaints_controller.rb
│   │   │   └── subscriptions_controller.rb
│   │   ├── users/
│   │   │   └── registrations_controller.rb  # Custom registration
│   │   ├── complaints_controller.rb
│   │   ├── drivers_controller.rb
│   │   ├── earnings_controller.rb
│   │   ├── kyc_documents_controller.rb
│   │   ├── pages_controller.rb
│   │   ├── payments_controller.rb
│   │   ├── rides_controller.rb
│   │   ├── subscriptions_controller.rb
│   │   └── webhooks_controller.rb    # Stripe webhooks
│   │
│   ├── models/
│   │   ├── complaint.rb
│   │   ├── kyc_document.rb
│   │   ├── payment.rb
│   │   ├── ride.rb                   # Geocoding, fare calculation
│   │   ├── subscription.rb
│   │   ├── user.rb                   # Roles, authentication
│   │   └── vehicle.rb
│   │
│   ├── services/
│   │   └── ride_matching_service.rb  # Driver matching algorithm
│   │
│   ├── views/
│   │   ├── admin/
│   │   │   ├── shared/
│   │   │   │   └── _nav.html.erb    # Admin navigation
│   │   │   ├── dashboard/
│   │   │   ├── drivers/
│   │   │   ├── vehicles/
│   │   │   ├── rides/
│   │   │   ├── kyc_documents/
│   │   │   ├── complaints/
│   │   │   └── subscriptions/
│   │   ├── complaints/
│   │   ├── earnings/
│   │   ├── kyc_documents/
│   │   ├── pages/
│   │   ├── rides/
│   │   └── subscriptions/
│   │
│   └── assets/
│       ├── stylesheets/
│       │   └── application.tailwind.css
│       └── javascript/
│           └── application.js
│
├── config/
│   ├── initializers/
│   │   ├── devise.rb
│   │   ├── geocoder.rb              # Geocoding configuration
│   │   └── stripe.rb                # Stripe API keys
│   ├── cable.yml                    # ActionCable/Redis config
│   ├── database.yml
│   └── routes.rb                    # All application routes
│
├── db/
│   ├── migrate/                     # All database migrations
│   └── schema.rb                    # Current database schema
│
└── README.md                        # This file
```

---

## Testing

### Running Tests

```bash
# Run all tests
rails test

# Run specific test file
rails test test/models/user_test.rb

# Run with coverage
COVERAGE=true rails test
```

### Test Structure

```
test/
├── controllers/
├── models/
├── integration/
├── channels/
└── fixtures/
```

### Testing Considerations

- Mock Stripe API calls in tests
- Use test Redis database
- Seed test data for realistic scenarios
- Test authorization for admin routes
- Test WebSocket connections

---

## Deployment

### Production Checklist

- [ ] Set all environment variables
- [ ] Configure production database (PostgreSQL)
- [ ] Set up Redis for ActionCable
- [ ] Configure Stripe webhook endpoints
- [ ] Set up SSL certificate
- [ ] Enable asset precompilation
- [ ] Configure Action Mailer for emails
- [ ] Set up background job processor (Sidekiq)
- [ ] Configure file storage (AWS S3 for Active Storage)
- [ ] Set up monitoring (e.g., New Relic, Sentry)

### Heroku Deployment

```bash
# Create Heroku app
heroku create trego-app

# Add Redis addon
heroku addons:create heroku-redis:hobby-dev

# Add PostgreSQL (automatically added)
heroku addons:create heroku-postgresql:hobby-dev

# Set environment variables
heroku config:set STRIPE_PUBLISHABLE_KEY=pk_live_xxx
heroku config:set STRIPE_SECRET_KEY=sk_live_xxx
heroku config:set MAPBOX_ACCESS_TOKEN=pk.xxx

# Deploy
git push heroku main

# Run migrations
heroku run rails db:migrate

# Create admin user
heroku run rails console
```

### AWS Deployment

For production-grade deployment:
- EC2 instances for app servers
- RDS for PostgreSQL
- ElastiCache for Redis
- S3 for file storage
- CloudFront for CDN
- Load Balancer for high availability

---

## Development Guidelines

### Code Style

- Follow Ruby Style Guide
- Use Rubocop for linting
- Write descriptive commit messages
- Keep methods small and focused

### Git Workflow

```bash
# Feature branch workflow
git checkout -b feature/new-feature
git commit -m "Add new feature"
git push origin feature/new-feature
# Create pull request
```

### Database Migrations

```bash
# Create migration
rails generate migration AddFieldToModel field:type

# Run migrations
rails db:migrate

# Rollback
rails db:rollback

# Reset database (caution!)
rails db:reset
```

---

## Troubleshooting

### Common Issues

**Redis Connection Error:**
```bash
# Check if Redis is running
redis-cli ping
# Should return "PONG"

# Start Redis
redis-server
```

**Stripe Webhooks Not Working:**
- Check webhook secret in `.env`
- Verify webhook endpoint URL
- Use Stripe CLI for local testing:
  ```bash
  stripe listen --forward-to localhost:3000/webhooks/stripe
  ```

**Geocoding Timeout:**
- Increase timeout in `config/initializers/geocoder.rb`
- Consider caching geocoded results

**ActionCable Not Connecting:**
- Verify Redis is running
- Check `config/cable.yml` configuration
- Ensure WebSocket support on server

---

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

---

## License

This project is proprietary software. All rights reserved.

---

## Support

For issues, questions, or contributions:
- Email: support@trego.com
- Issues: GitHub Issues
- Documentation: This README

---

## Acknowledgments

- **Ruby on Rails** - Web framework
- **Devise** - Authentication
- **Stripe** - Payment processing
- **Mapbox** - Mapping and geocoding
- **Tailwind CSS** - UI framework
- **ActionCable** - Real-time features

---

**Built with ❤️ using Ruby on Rails**
