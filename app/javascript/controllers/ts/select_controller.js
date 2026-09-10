import { Controller } from "@hotwired/stimulus"
import TomSelect      from "tom-select"

// Connects to data-controller="ts--select"
export default class extends Controller {
  connect() {
    this.tomSelect = new TomSelect(this.element)

    // A Turbo Stream can append a new <option> straight onto the underlying
    // <select> (e.g. after creating an entity inline without leaving the page).
    // Tom Select hides that select and manages its own UI, so re-sync it
    // whenever the native options change from outside Tom Select's control.
    this.observer = new MutationObserver(() => {
      // sync()/setValue() can themselves touch the native <select>, so stop
      // observing while handling a mutation to avoid triggering ourselves.
      this.observer.disconnect()
      this.tomSelect.sync()
      this.tomSelect.setValue(this.element.value, true)
      this.observer.observe(this.element, { childList: true })
    })
    this.observer.observe(this.element, { childList: true })
  }

  disconnect() {
    this.observer?.disconnect()
    this.tomSelect?.destroy()
  }
}
