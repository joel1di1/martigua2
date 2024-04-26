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

const SERVICE_WORKER_PATH = '/serviceworker.js';
const WEB_PUSH_SUBSCRIPTIONS_PATH = '/webpush_subscriptions';
const APPLICATION_SERVER_KEY = "BHgdMBM2bvdF6k4lkgInRs4QgeBzXohkaO6nOWMdQQji1PLggxT4hDCT02ZJqB6BG-lwUvnkqLZoL2OBnGCZZ6Q=";

const registerServiceWorker = async () => {
  try {
    await navigator.serviceWorker.register(SERVICE_WORKER_PATH);
    console.log('Service worker registered');
  } catch (error) {
    console.error('Error registering service worker:', error);
  }
};

const subscribeToPushManager = async (serviceWorkerRegistration) => {
  try {
    const subscription = await serviceWorkerRegistration.pushManager
      .subscribe({
        userVisibleOnly: true,
        applicationServerKey: urlB64ToUint8Array(APPLICATION_SERVER_KEY),
      });
    console.log('Subscribed to pushManager');
    return subscription;
  } catch (error) {
    console.error('Error subscribing to push manager:', error);
  }
};

const sendSubscriptionToServer = async (subscription) => {
  const csrfToken = document.querySelector('meta[name="csrf-token"]').content;
  try {
    const response = await fetch(WEB_PUSH_SUBSCRIPTIONS_PATH, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": csrfToken,
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
  } catch (error) {
    console.error('Error sending subscription to server:', error);
  }
};

document.addEventListener('turbo:load', () => {
  if (('serviceWorker' in navigator) && ('PushManager' in window)) {
    if (window.location.pathname.startsWith('/sections')) {
      registerServiceWorker();

      navigator.serviceWorker.ready.then(async (serviceWorkerRegistration) => {
        console.log('Service worker ready, checking subscription status');
        const existingSubscription = await serviceWorkerRegistration.pushManager.getSubscription();

        if (existingSubscription) {
          console.log('Already subscribed to pushManager');
        } else {
          const permission = await Notification.requestPermission();
          if (permission === 'granted') {
            const subscription = await subscribeToPushManager(serviceWorkerRegistration);
            if (subscription) {
              await sendSubscriptionToServer(subscription);
            }
          } else {
            console.log('Permission not granted for Notifications');
          }
        }
      });
    }
  }
});
