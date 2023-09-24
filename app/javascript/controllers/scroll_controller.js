import { Controller } from "@hotwired/stimulus";

// This file defines a Stimulus controller that handles scrolling in a chat interface.
// The controller marks messages as read when the user scrolls through them.
// It listens for scroll events on the chat interface and uses a set to keep track of newly read messages.
// When the user scrolls through unread messages, the controller adds their IDs to the set.
// If at least 2 seconds have passed since the last time the controller was called, it sends a POST request to the server to mark the messages as read.
// The controller then clears the set and removes the "unread" class from the corresponding message elements.
export default class extends Controller {
  static targets = ['messages'];

  connect() {
    this.scrollToLastReadMessage();

    this.visibleMessageIds = new Set();
    this.scrollTimeout = null;
    this.lastSentTime = null;

    this.messagesTarget.addEventListener('scroll', this.handleScroll);

    console.log('ScrollController connected');
  }

  disconnect() {
    clearTimeout(this.scrollTimeout);
    this.messagesTarget.removeEventListener('scroll', this.handleScroll);
  }

  // Marks messages as read when the user scrolls through them in a chat interface
  handleScroll() {
    this.newlyReadMessages ??= new Set();
    this.lastScheduledTime ??= 0;

    const messageElements = Array.from(this.querySelectorAll('.message'));

    const unreadMessageElements = messageElements.filter(messageElement => messageElement.classList.contains('unread'))

    const scrolledMessageElements =
      this.scrollTop >= this.scrollHeight - this.offsetHeight ? unreadMessageElements :
        unreadMessageElements.filter(messageElement => {
          const rect = messageElement.getBoundingClientRect();
          return rect.top >= 0 && rect.bottom + 120 <= (window.innerHeight || document.documentElement.clientHeight);
        })

    scrolledMessageElements.
      map(messageElement => messageElement.id).
      forEach(messageId => this.newlyReadMessages.add(messageId));

    const currentTime = Date.now();
    if (this.newlyReadMessages.size > 0 && currentTime - this.lastScheduledTime > 2000) {
      setTimeout(() => {
        fetch('/messages/mark_as_read', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
          },
          body: JSON.stringify({ message_ids: Array.from(this.newlyReadMessages).map(messageId => Number(messageId.replace('message_', ''))) })
        }).then(response => {
          if (response.ok){
            this.newlyReadMessages.forEach(messageId => this.querySelector(`#${messageId}`).classList.remove('unread'));
            this.newlyReadMessages.clear();
          } else {
          }
      })}, 2000);

      this.lastScheduledTime = currentTime;
    }
  }

  scrollToLastReadMessage() {
    // Find all read messages
    const readMessages = this.element.querySelectorAll('.message.read');

    // If found, scroll to the last read message
    if (readMessages.length > 0) {
      const lastReadMessage = readMessages[readMessages.length - 1];

      // Calculate the position to scroll to
      const container = this.element;
      const containerHeight = container.clientHeight;
      const messageHeight = lastReadMessage.clientHeight;
      const messageOffsetTop = lastReadMessage.offsetTop;
      const scrollPosition = messageOffsetTop - (containerHeight / 2) + (messageHeight / 2);

      // Scroll to the calculated position
      container.scrollTop = scrollPosition;
    }
  }
}
