import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "ffhbPlayerId", "userId"]

  dissociate(event) {
    console.log(event.params)

    this.ffhbPlayerIdTarget.value = event.params.ffhbPlayerId
    this.userIdTarget.value = event.params.userId
    this.formTarget.requestSubmit()

    event.preventDefault()
  }
}
