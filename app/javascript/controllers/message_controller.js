import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["message"]

  connect() {
    this.centralMessagesController = this.application.getControllerForElementAndIdentifier(document.getElementById("central-messages"), "central-messages");

    if (this.centralMessagesController.isScrollAtBottom()) {
      this.messageTarget.scrollIntoView();
    }
  }
}
