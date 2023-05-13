import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["message"]

  connect() {
    document.getElementById("central-messages").scrollTop = this.targetMessage.scrollHeight;
  }
}
