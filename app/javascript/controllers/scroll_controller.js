import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ['messages'];

  connect() {
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
          body: JSON.stringify({ message_ids: Array.from(this.newlyReadMessages) })
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
}
