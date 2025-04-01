/* eslint-env es6 */
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["left", "center", "right"];

  initialize() {
    this.touchStartX = 0;
    this.currentX = 0;
    this.isSwiping = false;
    this.currentIndex = 0;
  }

  connect() {
    console.log("Swipe controller connected");

    // Add touch event listeners
    this.element.addEventListener('touchstart', this.handleTouchStart.bind(this), false);
    this.element.addEventListener('touchmove', this.handleTouchMove.bind(this), false);
    this.element.addEventListener('touchend', this.handleTouchEnd.bind(this), false);
  }

  disconnect() {
    this.element.removeEventListener('touchstart', this.handleTouchStart);
    this.element.removeEventListener('touchmove', this.handleTouchMove);
    this.element.removeEventListener('touchend', this.handleTouchEnd);
  }

  handleTouchStart(event) {
    this.touchStartX = event.touches[0].clientX;
    this.currentX = this.touchStartX;
    this.isSwiping = true;

    // Remove transitions for immediate response
    this.leftTarget.style.transition = 'none';
    this.centerTarget.style.transition = 'none';
    this.rightTarget.style.transition = 'none';
  }

  test(event) {
    // toggle central div
    console.info("test");

    // if central is hidden, show it
    if (this.centerTarget.style.display === 'none') {
      this.centerTarget.style.display = 'block';
    } else {
      this.centerTarget.style.display = 'none';
    }
  }

  handleTouchMove(event) {
    if (!this.isSwiping) return;

    this.currentX = event.touches[0].clientX;
    let deltaX = this.currentX - this.touchStartX;

    // Limit swiping beyond available divs
    if (this.currentIndex === -1 && deltaX > 0) {
      // At leftmost position, prevent swiping right
      deltaX = 0;
    } else if (this.currentIndex === 1 && deltaX < 0) {
      // At rightmost position, prevent swiping left
      deltaX = 0;
    }

    // Calculate percentage movement relative to element width
    const percentage = (deltaX / this.element.offsetWidth) * 100;

    // Update positions with the percentage
    this.updatePositions(percentage);

    // stop propagation
    event.preventDefault();
  }

  handleTouchEnd(event) {
    if (!this.isSwiping) return;
    this.isSwiping = false;

    const deltaX = this.currentX - this.touchStartX;
    const swipeThreshold = this.element.offsetWidth * 0.25; // 25% of element width

    // Restore transitions for smooth animation
    this.leftTarget.style.transition = 'transform 0.3s ease';
    this.centerTarget.style.transition = 'transform 0.3s ease';
    this.rightTarget.style.transition = 'transform 0.3s ease';

    if (deltaX > swipeThreshold && this.currentIndex > -1) {
      // Swipe right
      this.currentIndex -= 1;
    } else if (deltaX < -swipeThreshold && this.currentIndex < 1) {
      // Swipe left
      this.currentIndex += 1;
    }
    // Else, stay at the same index

    // Snap to the closest position
    this.updatePositions(0);
  }

  updatePositions(percentage) {
    // Adjust the positions based on currentIndex and swipe percentage
    // if central is swiped to the left, right should be visible
    // if central is swiped to the right, left should be visible
    if (percentage < 0) {
      // hide left and show right
      this.leftTarget.style.display = 'none';
      this.rightTarget.style.display = 'block';
    } else if (percentage > 0) {
      // hide right and show left
      this.leftTarget.style.display = 'block';
      this.rightTarget.style.display = 'none';
    } else {
    }

    this.centerTarget.style.transform = `translateX(${this.currentIndex * -100 + percentage}%)`;
  }
}
