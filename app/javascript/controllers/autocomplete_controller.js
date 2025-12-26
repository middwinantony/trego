import { Controller } from "@hotwired/stimulus"

// Autocomplete controller for location search using Mapbox Geocoding API
export default class extends Controller {
  static targets = ["input", "results", "hiddenLatitude", "hiddenLongitude", "hiddenAddress"]
  static values = {
    url: String,
    accessToken: String
  }

  connect() {
    this.timeout = null
    this.debounceDelay = 300 // ms
  }

  // Handle input changes with debouncing
  search(event) {
    clearTimeout(this.timeout)

    const query = event.target.value.trim()

    if (query.length < 3) {
      this.hideResults()
      return
    }

    this.timeout = setTimeout(() => {
      this.performSearch(query)
    }, this.debounceDelay)
  }

  // Perform the search using fetch
  async performSearch(query) {
    try {
      const url = this.urlValue || `/rides/search?q=${encodeURIComponent(query)}`

      const response = await fetch(url, {
        headers: {
          "Accept": "text/vnd.turbo-stream.html",
          "X-Requested-With": "XMLHttpRequest"
        }
      })

      if (response.ok) {
        const html = await response.text()

        // If we have a results target, update it
        if (this.hasResultsTarget) {
          this.resultsTarget.innerHTML = html
          this.showResults()
        }
      }
    } catch (error) {
      console.error("Autocomplete search error:", error)
    }
  }

  // Select a location from results
  select(event) {
    event.preventDefault()

    const item = event.currentTarget
    const address = item.dataset.address
    const latitude = item.dataset.latitude
    const longitude = item.dataset.longitude
    const name = item.dataset.name || address

    // Update input value
    if (this.hasInputTarget) {
      this.inputTarget.value = address
    }

    // Update hidden fields if they exist
    if (this.hasHiddenLatitudeTarget) {
      this.hiddenLatitudeTarget.value = latitude
    }
    if (this.hasHiddenLongitudeTarget) {
      this.hiddenLongitudeTarget.value = longitude
    }
    if (this.hasHiddenAddressTarget) {
      this.hiddenAddressTarget.value = address
    }

    // Dispatch custom event for other controllers to listen to
    this.dispatch("selected", {
      detail: {
        address: address,
        latitude: latitude,
        longitude: longitude,
        name: name
      }
    })

    this.hideResults()
  }

  // Handle clicking outside to close results
  clickOutside(event) {
    if (!this.element.contains(event.target)) {
      this.hideResults()
    }
  }

  showResults() {
    if (this.hasResultsTarget) {
      this.resultsTarget.classList.remove("hidden")
    }
  }

  hideResults() {
    if (this.hasResultsTarget) {
      this.resultsTarget.classList.add("hidden")
    }
  }

  // Clear the input and hidden fields
  clear() {
    if (this.hasInputTarget) {
      this.inputTarget.value = ""
    }
    if (this.hasHiddenLatitudeTarget) {
      this.hiddenLatitudeTarget.value = ""
    }
    if (this.hasHiddenLongitudeTarget) {
      this.hiddenLongitudeTarget.value = ""
    }
    if (this.hasHiddenAddressTarget) {
      this.hiddenAddressTarget.value = ""
    }
    this.hideResults()
  }
}
