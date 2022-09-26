import { Controller } from "@hotwired/stimulus"
import { enter, leave } from 'el-transition';

export default class extends Controller {
  static targets = ["menu"]
  static values = { open: Boolean }

  toggle() {
    this.openValue = !this.openValue
  }

  // hide(event) {
  //   if (this.element.contains(event.target) === false && this.openValue) {
  //     this.openValue = false
  //   }
  // }

  openValueChanged() {
    this.openValue ? enter(this.menuTarget) : leave(this.menuTarget)
  }
}
