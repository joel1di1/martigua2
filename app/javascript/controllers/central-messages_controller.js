import { Controller } from "@hotwired/stimulus";

export default class extends Controller {

  static targets = ['scroll', 'message'];

  isScrollAtBottom() {
    return this.scrollTarget.scrollHeight - this.scrollTarget.scrollTop === this.scrollTarget.clientHeight;
  }
}
