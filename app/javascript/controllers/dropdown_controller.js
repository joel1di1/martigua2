import { Controller } from "@hotwired/stimulus"
import { enter, leave } from 'el-transition';

export default class extends Controller {
  static targets = ["menu"]
  static values = { open: Boolean, urlParam: String  }

  toggle(event) {
    this.openValue = !this.openValue
    if (this.hasUrlParamValue){
      const url = new URL(window.location.href)
      url.searchParams.delete(this.urlParamValue)
      url.searchParams.append(this.urlParamValue, this.openValue)
      window.history.pushState({}, '', url)
    }
  }

  hide(event) {
    if (this.element.contains(event.target) === false && this.openValue) {
      this.openValue = false
    }
  }

  openValueChanged() {
    this.openValue ? enter(this.menuTarget) : leave(this.menuTarget)
  }
}
