import { Controller } from "@hotwired/stimulus";

export default class extends Controller {

  static targets = ['scroll', 'message'];

  isScrollAtBottom(currentMessage) {
    // for all messages div, they have ids like "message_<n>"
    // we want to check if the last message, unless the current _one is visible
    // if it's not the case, we don't want to scroll to the bottom
    // because the user is reading old messages

    // messages except the current one
    const messages = this.messageTargets.filter(message => message.id !== currentMessage.id);

    // last message
    const lastMessage = messages[messages.length - 1];

    // if the last message is not visible, we don't want to scroll to the bottom
    return this.isChildVisibleInScrollableElement(this.scrollTarget, lastMessage);
  }


  isChildVisibleInScrollableElement(scrollableElement, childElement) {
    const scrollableRect = scrollableElement.getBoundingClientRect();
    const childRect = childElement.getBoundingClientRect();

    return (
        childRect.top >= scrollableRect.top &&
        childRect.bottom <= scrollableRect.bottom &&
        childRect.left >= scrollableRect.left &&
        childRect.right <= scrollableRect.right
    );
  }
}
