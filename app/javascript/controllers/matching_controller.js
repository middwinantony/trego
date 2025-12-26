import { Controller } from "@hotwired/stimulus"
import { createConsumer } from "@rails/actioncable"

// Controller for matching screen - listens for driver assignment via ActionCable
export default class extends Controller {
  static values = {
    rideId: Number
  }

  connect() {
    console.log("Matching controller connected for ride:", this.rideIdValue)

    // Subscribe to RideChannel for this specific ride
    this.subscription = createConsumer().subscriptions.create(
      {
        channel: "RideChannel",
        ride_id: this.rideIdValue
      },
      {
        connected: this.cableConnected.bind(this),
        disconnected: this.cableDisconnected.bind(this),
        received: this.cableReceived.bind(this)
      }
    )
  }

  disconnect() {
    if (this.subscription) {
      this.subscription.unsubscribe()
    }
  }

  cableConnected() {
    console.log("Connected to RideChannel")
  }

  cableDisconnected() {
    console.log("Disconnected from RideChannel")
  }

  cableReceived(data) {
    console.log("Received data from RideChannel:", data)

    // Check if driver was assigned
    if (data.type === "driver_assigned" || data.status === "accepted") {
      this.handleDriverAssigned(data)
    }

    // Check for matching updates
    if (data.type === "matching_update") {
      this.updateMatchingStatus(data.message)
    }
  }

  handleDriverAssigned(data) {
    console.log("Driver assigned! Redirecting to driver assigned screen...")

    // Show success message briefly before redirect
    this.showSuccessMessage()

    // Redirect to driver assigned screen after short delay
    setTimeout(() => {
      window.location.href = `/rides/${this.rideIdValue}`
    }, 1500)
  }

  showSuccessMessage() {
    const messageElement = this.element.querySelector("[data-matching-target='message']")
    if (messageElement) {
      messageElement.textContent = "Driver found! Loading details..."
      messageElement.classList.add("text-green-600", "font-semibold")
    }

    const spinnerElement = this.element.querySelector("[data-matching-target='spinner']")
    if (spinnerElement) {
      spinnerElement.innerHTML = `
        <svg class="w-16 h-16 text-green-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path>
        </svg>
      `
    }
  }

  updateMatchingStatus(message) {
    const messageElement = this.element.querySelector("[data-matching-target='message']")
    if (messageElement && message) {
      messageElement.textContent = message
    }
  }

  // Handle cancel button click
  cancel() {
    if (confirm("Are you sure you want to cancel this ride request?")) {
      // Send cancel request
      fetch(`/rides/${this.rideIdValue}`, {
        method: "PATCH",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": document.querySelector("[name='csrf-token']").content
        },
        body: JSON.stringify({
          ride: {
            status: "cancelled"
          }
        })
      }).then(response => {
        if (response.ok) {
          window.location.href = "/rides"
        }
      })
    }
  }
}
