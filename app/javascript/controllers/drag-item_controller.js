import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  dragstart(event) {
    event.dataTransfer.setData("application/drag-key", event.target.getAttribute("data-player-id"))
    event.dataTransfer.effectAllowed = "move"
  }

  dragover(event) {
    event.preventDefault()
    return true
  }

  dragenter(event) {
    event.preventDefault()
  }

  drop(event) {
    var data = event.dataTransfer.getData("application/drag-key")
    const dropTarget = event.target
    const draggedItem = this.element.querySelector(`[data-todo-id='${data}']`);
    // const positionComparison = dropTarget.compareDocumentPosition(draggedItem)
    // if ( positionComparison & 4) {
    //     // event.target.insertAdjacentElement('beforebegin', draggedItem);
    // } else if ( positionComparison & 2) {
    //     // event.target.insertAdjacentElement('afterend', draggedItem);
    // }
    event.preventDefault()
    // alert('drop')
  }

  dragend(event) {
  }
}
