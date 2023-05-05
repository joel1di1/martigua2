// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import "trix"
import "@rails/actiontext"

// Register the serviceWorker script at /serviceworker.js from your server if supported
if (navigator.serviceWorker) {
  navigator.serviceWorker.register('/serviceworker.js')
    .then(function (reg) {
      console.log('Service worker change, registered the service worker');
    });

  // When serviceWorker is supported, installed, and activated,
  // subscribe the pushManager property with the vapidPublicKey
  navigator.serviceWorker.ready.then((serviceWorkerRegistration) => {
    console.log('Service worker ready, subscribing to pushManager');
    serviceWorkerRegistration.pushManager
      .subscribe({
        userVisibleOnly: true,
        applicationServerKey: new Uint8Array([4, 159, 142, 201, 185, 96, 212, 230, 225, 246, 148, 41, 103, 21, 125, 175, 74, 184, 68, 150, 208, 160, 98, 88, 23, 190, 193, 60, 228, 226, 193, 165, 27, 206, 2, 49, 82, 212, 8, 135, 33, 239, 244, 89, 170, 96, 31, 112, 111, 246, 50, 1, 34, 196, 224, 41, 111, 36, 179, 191, 72, 106, 140, 229, 45]),
      });
    console.log('Subscribed to pushManager');
  });

}
// Otherwise, no push notifications :(
else {
  console.error('Service worker is not supported in this browser');
}


