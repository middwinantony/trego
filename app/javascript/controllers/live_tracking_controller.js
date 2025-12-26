import { Controller } from "@hotwired/stimulus"
import { createConsumer } from "@rails/actioncable"

// Controller for live ride tracking with real-time driver location updates
export default class extends Controller {
  static values = {
    rideId: Number,
    accessToken: String
  }

  static targets = ["map", "eta", "distance", "progressBar"]

  connect() {
    console.log("Live tracking controller connected for ride:", this.rideIdValue)

    // Initialize map if target exists
    if (this.hasMapTarget) {
      this.initializeMap()
    }

    // Subscribe to ride updates via ActionCable
    this.subscribeToRide()
  }

  disconnect() {
    if (this.subscription) {
      this.subscription.unsubscribe()
    }
  }

  initializeMap() {
    // Get initial ride data from data attributes
    const pickupLat = parseFloat(this.mapTarget.dataset.pickupLat)
    const pickupLng = parseFloat(this.mapTarget.dataset.pickupLng)
    const dropoffLat = parseFloat(this.mapTarget.dataset.dropoffLat)
    const dropoffLng = parseFloat(this.mapTarget.dataset.dropoffLng)
    const driverLat = parseFloat(this.mapTarget.dataset.driverLat)
    const driverLng = parseFloat(this.mapTarget.dataset.driverLng)

    // Initialize Mapbox map
    mapboxgl.accessToken = this.accessTokenValue || this.mapTarget.dataset.accessToken

    this.map = new mapboxgl.Map({
      container: this.mapTarget,
      style: 'mapbox://styles/mapbox/streets-v12',
      center: [pickupLng, pickupLat],
      zoom: 13
    })

    // Add navigation controls
    this.map.addControl(new mapboxgl.NavigationControl())

    this.map.on('load', () => {
      // Add pickup marker (green)
      new mapboxgl.Marker({ color: '#10b981' })
        .setLngLat([pickupLng, pickupLat])
        .setPopup(new mapboxgl.Popup().setHTML('<p>Pickup Location</p>'))
        .addTo(this.map)

      // Add dropoff marker (red)
      new mapboxgl.Marker({ color: '#ef4444' })
        .setLngLat([dropoffLng, dropoffLat])
        .setPopup(new mapboxgl.Popup().setHTML('<p>Dropoff Location</p>'))
        .addTo(this.map)

      // Add driver marker (blue) if available
      if (driverLat && driverLng) {
        this.driverMarker = new mapboxgl.Marker({ color: '#3b82f6' })
          .setLngLat([driverLng, driverLat])
          .setPopup(new mapboxgl.Popup().setHTML('<p>Driver Location</p>'))
          .addTo(this.map)
      }

      // Fit bounds to show all markers
      const bounds = new mapboxgl.LngLatBounds()
      bounds.extend([pickupLng, pickupLat])
      bounds.extend([dropoffLng, dropoffLat])
      if (driverLat && driverLng) {
        bounds.extend([driverLng, driverLat])
      }

      this.map.fitBounds(bounds, { padding: 50 })

      // Add route line
      this.addRouteLine([pickupLng, pickupLat], [dropoffLng, dropoffLat])
    })
  }

  addRouteLine(start, end) {
    // Add a simple straight line for the route (in production, use Mapbox Directions API)
    this.map.addSource('route', {
      'type': 'geojson',
      'data': {
        'type': 'Feature',
        'geometry': {
          'type': 'LineString',
          'coordinates': [start, end]
        }
      }
    })

    this.map.addLayer({
      'id': 'route',
      'type': 'line',
      'source': 'route',
      'layout': {
        'line-join': 'round',
        'line-cap': 'round'
      },
      'paint': {
        'line-color': '#3b82f6',
        'line-width': 4
      }
    })
  }

  subscribeToRide() {
    this.subscription = createConsumer().subscriptions.create(
      {
        channel: "RideChannel",
        ride_id: this.rideIdValue
      },
      {
        connected: this.cableConnected.bind(this),
        received: this.cableReceived.bind(this)
      }
    )
  }

  cableConnected() {
    console.log("Connected to RideChannel for live tracking")
  }

  cableReceived(data) {
    console.log("Received tracking data:", data)

    // Update driver location on map
    if (data.type === "location_update" && data.driver_latitude && data.driver_longitude) {
      this.updateDriverLocation(data.driver_latitude, data.driver_longitude)
    }

    // Update ETA
    if (data.eta) {
      this.updateETA(data.eta)
    }

    // Update distance remaining
    if (data.distance_remaining) {
      this.updateDistance(data.distance_remaining)
    }

    // Update progress
    if (data.progress_percentage) {
      this.updateProgress(data.progress_percentage)
    }

    // Handle ride completion
    if (data.status === "completed" || data.type === "ride_completed") {
      this.handleRideCompleted()
    }
  }

  updateDriverLocation(latitude, longitude) {
    if (this.driverMarker && this.map) {
      // Smoothly animate marker to new position
      this.driverMarker.setLngLat([longitude, latitude])

      // Optionally recenter map to include driver
      const bounds = new mapboxgl.LngLatBounds()
      bounds.extend([longitude, latitude])
      bounds.extend(this.driverMarker.getLngLat())

      // Don't auto-recenter if user is panning the map
      // this.map.fitBounds(bounds, { padding: 50, duration: 1000 })
    }
  }

  updateETA(eta) {
    if (this.hasEtaTarget) {
      this.etaTarget.textContent = `${eta} min`
    }
  }

  updateDistance(distance) {
    if (this.hasDistanceTarget) {
      this.distanceTarget.textContent = `${distance.toFixed(1)} km`
    }
  }

  updateProgress(percentage) {
    if (this.hasProgressBarTarget) {
      this.progressBarTarget.style.width = `${percentage}%`
    }
  }

  handleRideCompleted() {
    console.log("Ride completed! Redirecting to completion screen...")

    setTimeout(() => {
      window.location.href = `/rides/${this.rideIdValue}`
    }, 2000)
  }
}
