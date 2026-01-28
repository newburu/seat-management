import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container", "template"]

  add(event) {
    event.preventDefault()
    
    // Clone the template content
    const content = this.templateTarget.content.cloneNode(true)
    
    // Generate a unique index for the fields to behave like nested attributes (though we handle manually in controller)
    const index = new Date().getTime()
    const fields = content.querySelectorAll('input')
    fields.forEach(field => {
      field.name = field.name.replace('TEMPLATE_INDEX', index)
    })

    this.containerTarget.appendChild(content)
  }

  remove(event) {
    event.preventDefault()
    event.target.closest('.property-field').remove()
  }
}
