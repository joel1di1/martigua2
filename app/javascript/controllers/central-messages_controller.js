import { Controller } from "@hotwired/stimulus";

export default class extends Controller {

  static targets = ['scroll'];

  connect() {
    this.frameLoadHandler = this.frameLoad.bind(this);
    document.addEventListener("turbo:load", this.frameLoadHandler);

    this.streamRenderHandler = this.streamRender.bind(this);
    document.addEventListener("turbo:before-stream-render", this.streamRenderHandler);

    this.turboRenderHandler = this.turboRender.bind(this);
    document.addEventListener("turbo:render", this.turboRenderHandler);
  }

  disconnect() {
    document.removeEventListener("turbo:load", this.frameLoadHandler);
    document.removeEventListener("turbo:render", this.turboRenderHandler);
  }

  frameLoad() {
    console.log("frame load !");
    this.scrollToBottom();
  }

  streamRender(event) {
    console.log("Before stream render: ");
    this.scrollTarget.scrollTop = this.scrollTarget.scrollHeight;
    }

  turboRender(event) {
    console.log("Turbo rendered");
    // Your custom scrolling logic here
  }

  scrollToBottom() {
    this.scrollTarget.scrollTop = this.scrollTarget.scrollHeight;
  }
}
