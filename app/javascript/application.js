// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
esversion: 6

import "@hotwired/turbo-rails"
import "controllers"
import "trix"
import "@rails/actiontext"

function urlB64ToUint8Array(base64String) {
  const padding = '='.repeat((4 - (base64String.length % 4)) % 4); // Ajoute le padding
  const base64 = (base64String + padding)
    .replace(/\-/g, '+') // Remplace les caractères '-' par '+'
    .replace(/_/g, '/'); // Remplace les caractères '_' par '/'
  const rawData = window.atob(base64); // Décode la chaîne de caractères avec la fonction window.atob
  const outputArray = new Uint8Array(rawData.length); // Crée un tableau de sortie
  for (let i = 0; i < rawData.length; ++i) {
    outputArray[i] = rawData.charCodeAt(i); // Convertit les caractères en nombres
  }
  return outputArray;
}

// Register the serviceWorker script at /serviceworker.js from your server if supported
if (navigator.serviceWorker) {
  Notification.requestPermission();
  navigator.serviceWorker.register('/serviceworker.js')
    .then(function (reg) {
      console.log('Service worker change, registered the service worker');
    });

  // When serviceWorker is supported, installed, and activated,
  // subscribe the pushManager property with the vapidPublicKey
  navigator.serviceWorker.ready.then(async (serviceWorkerRegistration) => {
    console.log('Service worker ready, subscribing to pushManager');
    const subscription = await serviceWorkerRegistration.pushManager
      .subscribe({
        userVisibleOnly: true,
        applicationServerKey: urlB64ToUint8Array("BHgdMBM2bvdF6k4lkgInRs4QgeBzXohkaO6nOWMdQQji1PLggxT4hDCT02ZJqB6BG-lwUvnkqLZoL2OBnGCZZ6Q="),
      });
    console.log('Subscribed to pushManager');

    // Récupère le jeton CSRF
    const csrfToken = document.querySelector('meta[name="csrf-token"]').content;

    // Envoie les informations d'abonnement au serveur
    const response = await fetch("/webpush_subscriptions", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": csrfToken, // Ajoutez le jeton CSRF à l'en-tête
      },
      body: JSON.stringify({
        endpoint: subscription.endpoint,
        p256dh_key: btoa(String.fromCharCode.apply(null, new Uint8Array(subscription.getKey("p256dh")))),
        auth_key: btoa(String.fromCharCode.apply(null, new Uint8Array(subscription.getKey("auth")))),
      }),
    });

    if (response.ok) {
      console.log("Abonnement aux notifications enregistré côté serveur");
    } else {
      console.error("Erreur lors de l'enregistrement de l'abonnement côté serveur");
    }

  });
}
// Otherwise, no push notifications :(
else {
  console.error('Service worker is not supported in this browser');
}

