import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ['team1', 'team2']

  switch(event) {
    var tmp = this.team1Target.value
    this.team1Target.value = this.team2Target.value
    this.team2Target.value = tmp
  }
}
