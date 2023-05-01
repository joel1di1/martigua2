import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["textarea"];

  connect() {
    this.submitOnCmdEnter = this.submitOnCmdEnter.bind(this);
    this.textareaTarget.addEventListener("keydown", this.submitOnCmdEnter);
  }

  disconnect() {
    this.textareaTarget.removeEventListener("keydown", this.submitOnCmdEnter);
  }

  submitOnCmdEnter(event) {
    const isCmdOrCtrl = event.metaKey || event.ctrlKey;
    const isEnter = event.key === "Enter";

    if (isCmdOrCtrl && isEnter) {
      event.preventDefault(); // Empêche l'insertion d'un retour à la ligne
      this.element.submit(); // Soumet le formulaire
    }
  }
}
