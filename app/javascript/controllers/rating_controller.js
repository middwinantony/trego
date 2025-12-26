import { Controller } from "@hotwired/stimulus"

// Controller for rating (star selection) and tip functionality
export default class extends Controller {
  static targets = ["star", "hiddenScore", "tipButton", "hiddenTip", "customTipInput"]
  static values = {
    score: Number,
    tipAmount: Number
  }

  connect() {
    this.scoreValue = 0
    this.tipAmountValue = 0
  }

  // Handle star hover
  hoverStar(event) {
    const hoveredIndex = parseInt(event.currentTarget.dataset.index)

    this.starTargets.forEach((star, index) => {
      if (index < hoveredIndex) {
        star.classList.add("text-yellow-400")
        star.classList.remove("text-gray-300")
      } else {
        star.classList.remove("text-yellow-400")
        star.classList.add("text-gray-300")
      }
    })
  }

  // Handle mouse leave from stars
  leaveStar() {
    // Restore to selected state
    this.updateStarDisplay(this.scoreValue)
  }

  // Handle star click (selection)
  selectStar(event) {
    const selectedIndex = parseInt(event.currentTarget.dataset.index)
    this.scoreValue = selectedIndex

    // Update hidden input
    if (this.hasHiddenScoreTarget) {
      this.hiddenScoreTarget.value = selectedIndex
    }

    // Update star display
    this.updateStarDisplay(selectedIndex)

    // Dispatch event
    this.dispatch("rated", {
      detail: { score: selectedIndex }
    })
  }

  updateStarDisplay(score) {
    this.starTargets.forEach((star, index) => {
      if (index < score) {
        star.classList.add("text-yellow-400")
        star.classList.remove("text-gray-300")
      } else {
        star.classList.remove("text-yellow-400")
        star.classList.add("text-gray-300")
      }
    })
  }

  // Handle tip button selection
  selectTip(event) {
    const button = event.currentTarget
    const tipAmount = parseFloat(button.dataset.amount)

    // Remove selected state from all buttons
    this.tipButtonTargets.forEach(btn => {
      btn.classList.remove("bg-blue-600", "text-white", "border-blue-600")
      btn.classList.add("bg-white", "text-gray-700", "border-gray-300")
    })

    // Add selected state to clicked button
    button.classList.remove("bg-white", "text-gray-700", "border-gray-300")
    button.classList.add("bg-blue-600", "text-white", "border-blue-600")

    // Update tip amount
    this.tipAmountValue = tipAmount

    // Update hidden input
    if (this.hasHiddenTipTarget) {
      this.hiddenTipTarget.value = tipAmount
    }

    // Clear custom tip input
    if (this.hasCustomTipInputTarget) {
      this.customTipInputTarget.value = ""
    }

    // Dispatch event
    this.dispatch("tip-selected", {
      detail: { amount: tipAmount }
    })
  }

  // Handle custom tip input
  customTipChanged(event) {
    const customAmount = parseFloat(event.target.value) || 0

    // Remove selected state from all preset buttons
    this.tipButtonTargets.forEach(btn => {
      btn.classList.remove("bg-blue-600", "text-white", "border-blue-600")
      btn.classList.add("bg-white", "text-gray-700", "border-gray-300")
    })

    // Update tip amount
    this.tipAmountValue = customAmount

    // Update hidden input
    if (this.hasHiddenTipTarget) {
      this.hiddenTipTarget.value = customAmount
    }

    // Dispatch event
    this.dispatch("tip-selected", {
      detail: { amount: customAmount }
    })
  }

  // Get current rating score
  getScore() {
    return this.scoreValue
  }

  // Get current tip amount
  getTipAmount() {
    return this.tipAmountValue
  }

  // Validate before submission
  validate() {
    if (this.scoreValue === 0) {
      alert("Please select a rating")
      return false
    }
    return true
  }
}
