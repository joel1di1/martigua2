import { Controller } from "@hotwired/stimulus";

/*
 * Usage
 * =====
 *
 * add data-controller="auto-submit" to your <form> element
 *
 * Action (add this to a <select> field):
 * data-action="change->auto-submit#submit"
 *
 */
export default class extends Controller {
  static targets = ["form"]

  submit() {
    this.formTarget.requestSubmit()
  }
}
