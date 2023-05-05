import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  reset() {
    this.element.reset()
    const centralDiv = document.getElementById("central-messages");
    centralDiv.scrollTop = centralDiv.scrollHeight;
  }
}