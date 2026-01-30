import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button", "text", "loading"]

  connect() {
    // console.log("Loading controller connected")
  }

  submitStart() {
    this.buttonTarget.setAttribute("disabled", "disabled")
    this.buttonTarget.classList.add("opacity-75", "cursor-not-allowed")
    this.textTarget.classList.add("hidden")
    this.loadingTarget.classList.remove("hidden")
  }

  submitEnd() {
    this.buttonTarget.removeAttribute("disabled")
    this.buttonTarget.classList.remove("opacity-75", "cursor-not-allowed")
    this.textTarget.classList.remove("hidden")
    this.loadingTarget.classList.add("hidden")
  }
}
