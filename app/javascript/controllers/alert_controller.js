import { Controller } from "@hotwired/stimulus"
import { enter, leave } from 'el-transition';

export default class extends Controller {
  static targets = ["panel"]

  dismiss() {
    leave(this.panelTarget)
  }

  connect() {
    enter(this.panelTarget)
  }
}
