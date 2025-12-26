import { Controller } from "@hotwired/stimulus"

// Controller for ride type selection (Economy, Comfort, Premium, XL)
export default class extends Controller {
  static targets = ["card", "hiddenInput", "submitButton"]
  static values = {
    selectedType: String
  }

  connect() {
    // Restore previously selected option if any
    if (this.hasSelectedTypeValue && this.selectedTypeValue) {
      this.selectType({ currentTarget: this.findCardByType(this.selectedTypeValue) }, false)
    }
  }

  // Handle ride type card selection
  select(event) {
    const card = event.currentTarget
    const rideType = card.dataset.rideType

    if (!rideType) return

    // Remove selected state from all cards
    this.cardTargets.forEach(c => {
      c.classList.remove("border-blue-500", "bg-blue-50", "ring-2", "ring-blue-500")
      c.classList.add("border-gray-300")
    })

    // Add selected state to clicked card
    card.classList.remove("border-gray-300")
    card.classList.add("border-blue-500", "bg-blue-50", "ring-2", "ring-blue-500")

    // Update hidden input value
    if (this.hasHiddenInputTarget) {
      this.hiddenInputTarget.value = rideType
    }

    // Store selected type
    this.selectedTypeValue = rideType

    // Enable submit button
    this.enableSubmitButton()

    // Dispatch custom event
    this.dispatch("selected", {
      detail: {
        rideType: rideType,
        card: card
      }
    })
  }

  // Enable the submit/confirm button
  enableSubmitButton() {
    if (this.hasSubmitButtonTarget) {
      this.submitButtonTarget.disabled = false
      this.submitButtonTarget.classList.remove("opacity-50", "cursor-not-allowed")
      this.submitButtonTarget.classList.add("hover:bg-blue-700", "cursor-pointer")
    }
  }

  // Find card element by ride type
  findCardByType(rideType) {
    return this.cardTargets.find(card => card.dataset.rideType === rideType)
  }

  // Get currently selected ride type
  getSelectedType() {
    return this.selectedTypeValue || null
  }
}
