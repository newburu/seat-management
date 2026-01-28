import { Controller } from "@hotwired/stimulus"
import Sortable from "sortablejs"

export default class extends Controller {
  static values = { groupName: String }

  connect() {
    this.sortable = new Sortable(this.element, {
      group: this.groupNameValue || 'shared',
      animation: 150,
      ghostClass: 'bg-blue-100',
      onEnd: this.end.bind(this)
    })
  }

  disconnect() {
    this.sortable.destroy()
  }

  end(event) {
    // Here we could send an ajax request to update the backend
    console.log("Moved item from", event.from, "to", event.to)
  }
}
