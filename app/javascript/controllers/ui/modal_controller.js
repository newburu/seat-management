import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.boundClose = this.close.bind(this)
  }

  close(e) {
    if (e) e.preventDefault()
    this.element.remove()
  }

  closeBackground(e) {
    if (e.target === this.element) {
      this.close(e)
    }
  }

  handleKeyup(e) {
    if (e.code === "Escape") {
      this.close(e)
    }
  }
}
